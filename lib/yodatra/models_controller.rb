module Yodatra
  # This is a generic model controller that expose a REST API for your models.
  # The responses are encoded in JSON.
  #
  # Simply create your controller that inherits from this class, keeping the naming convention.
  #
  # For example, given a `User` model, creating a `class UsersController < Yodatra::ModelsController`, it will expose these routes:
  #
  #  GET /users
  # > retrieves all users _(attributes exposed are limited by the <b>read_scope</b> method defined in the <b>UsersController</b>)_
  #
  #  GET /users/:id
  # > retrieves a user _(attributes exposed are limited by the `read_scope`` method defined in the `UsersController`)_
  #
  #  POST /users
  # > creates a user _(attributes assignable are limited by the `user_params` method defined in the `UsersController`)_
  #
  #  PUT /users/:id
  # > updates a user _(attributes assignable are limited by the `user_params` method defined in the `UsersController`)_
  #
  #  DELETE /users/:id
  # > deletes a user
  #
  # If your model is referenced by another model, nested routes are also created for you. And you don't need to worry about the references/joins, they are done automaticly!
  # For example, imagine a `Team` model that has many `User`s, the following routes will be exposed:
  #
  #  GET /team/:team_id/users
  #
  #  GET /team/:team_id/users/:id
  #
  #  POST /team/:team_id/users
  #
  #  PUT /team/:team_id/users/:id
  #
  #  DESTROY /team/:team_id/users/:id
  #
  # === Note:
  # You can disable any of these actions by using the __::disable__ class method
  # and providing the list of actions you want to disable
  #  disable :read, :read_all, :create, :update, :delete, :nested_read_all, :nested_delete
  #
  # === Extra:
  # You can enable a special "search" action by using the __::enable_search_on__ class method
  #  enable_search_on :name
  class ModelsController < Sinatra::Base

    # Generic route to target ONE resource
    ONE_ROUTE =
        %r{\A/([\w]+?)/([0-9]+)(?:/([\w]+?)/([0-9]+)){0,1}\Z}

    # Generic route to target ALL resources
    ALL_ROUTE =
        %r{\A/([\w]+?)(?:/([0-9]+)/([\w]+?)){0,1}\Z}

    # Search route
    SEARCH_ROUTE =
      %r{\A/([\w]+?)(?:/([0-9]+)/([\w]+?)){0,1}/search\Z}

    before do
      content_type 'application/json'
    end

    READ_ALL = :read_all
    get ALL_ROUTE do
      retrieve_resources READ_ALL do |resource|
        resource.all.as_json(read_scope)
      end
    end

    READ_ONE = :read
    get ONE_ROUTE do
      retrieve_resources READ_ONE do |resource|
        resource.as_json(read_scope)
      end
    end

    CREATE_ONE = :create
    post ALL_ROUTE do
      retrieve_resources CREATE_ONE do |resource|
        hash = self.send("#{model_name.underscore}_params".to_sym)
        @one = resource.create hash

        if @one.id.nil?
          status 400
          @one.errors.full_messages
        else
          @one.as_json(read_scope)
        end
      end
    end

    UPDATE_ONE = :update
    put ONE_ROUTE do
      retrieve_resources UPDATE_ONE do |resource|
        hash = self.send("#{model_name.underscore}_params".to_sym)
        if resource.update_attributes(hash)
          resource.as_json(read_scope)
        else
          status 400
          resource.errors.full_messages
        end
      end
    end

    DELETE_ONE = :delete
    delete ONE_ROUTE do
      retrieve_resources DELETE_ONE do |resource|
        if resource.destroy
          resource.as_json(read_scope)
        else
          status 400
          resource.errors.full_messages
        end
      end
    end

    class << self
      def model_name
        self.name.split('::').last.gsub(/sController/, '')
      end

      def model
        model_name.constantize
      end

      # This helper gives the ability to disable default root by specifying
      # a list of routes to disable.
      # @param *opts list of routes to disable (e.g. :create, :destroy)
      def disable(*opts)
        opts.each do |key|
          method = "#{key}_disabled?".to_sym
          undef_method method if method_defined? method
          define_method method, Proc.new {|| true}
        end
      end

      # This class method enables the search routes `/resoures/search?q=search+terms` for the model.
      # The search will be performed on all the attributes given in parameter of this method.
      # E.g. if you enabled the search on `:name` and `:email` attrs
      # a GET /resources/search?q=john+doe
      # will return all `Resource` instance where the name or the email matches either "john" or "doe"
      def enable_search_on(*attributes)
        self.instance_eval do
          get SEARCH_ROUTE do
            retrieve_resources '' do |resource|

              pass if !involved? || params[:q].blank? || params[:q].size > 100

              terms = params[:q].split(/[\+ ]/)
              search_terms = []

              # Seperate terms to match
              terms.each do |term|
                attributes.each do |attr|
                  search_terms << resource.arel_table[attr.to_sym].matches("%#{term}%")
                end
              end

              resource.where(search_terms.reduce(:or)).limit(100).
                flatten.as_json(read_scope)
            end
          end
        end
      end
    end

    private

    # Defines a nested route or not and retrieves the correct resource (or resources)
    # @param disables is the name to check if it was disabled
    # @param &block to be yield with the retrieved resource
    # @returns resource in json format
    def retrieve_resources(action)
      pass unless involved?
      no_route if disabled? action

      model = model_name.constantize
      nested = nested_resources if nested?

      if model.nil? || nested.nil? && nested?
        raise ActiveRecord::RecordNotFound
      else
        resource = nested? ? nested : model

        # Check access to the resource
        method = "limit_#{action}_for".to_sym
        resource = self.class.send(method, resource, current_user) if self.class.respond_to?(method) && !current_user.nil?

        # ONE resource else COLLECTION
        one_id = nested? ? params[:captures].fourth : params[:captures].second if params[:captures].length == 4
        resource = resource.find one_id unless one_id.nil?
        yield(resource).to_json
      end
    rescue ActiveRecord::RecordNotFound
      record_not_found.to_json
    end

    def nested?
      params[:captures].length >= 3 && params[:captures].first(3).none?(&:nil?)
    end

    def nested_resources
      resources = nil
      begin
        parent_model = params[:captures].first.classify.constantize
        parent_controller = "#{parent_model}sController".constantize
      rescue NameError
        parent_model = nil
        parent_controller = nil
      end

      unless parent_model.nil?
        parent_model = parent_controller.limit_read_for parent_model, current_user if parent_controller.respond_to?(:limit_read_for) && !current_user.nil?
        parent = parent_model.find params[:captures].second
        if parent.respond_to? :reflections
          # This is AR 4.0.x compatibility
          has_association = !parent.reflections[involved.to_sym].nil?
        else
          # This is AR 4.1.x compatibility
          has_association = !parent._reflections[involved.to_sym].nil?
        end
        resources = parent.send(involved.to_sym) if has_association
      end
      resources
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def involved
      involved = params[:splat] && params[:splat].first
      params[:captures].each_index { |i|
        involved ||= params[:captures].last(i+1).first if !params[:captures].last(i+1).first.nil? && params[:captures].last(i+1).first.match(/[\d]+/).nil?
      } unless params[:captures].nil?
      involved
    end

    def involved?
      !involved.match(/\A#{model_name.underscore}[s]?\Z/).nil?
    end

    # read_scope defaults to all attrs of the model
    def read_scope
      {}
    end

    # create/update scope defaults to all data given in the POST/PUT
    def method_missing(name, *args)
      if name.to_s == "#{model_name.underscore}_params"
        return params.reject{|k,v| %w(splat captures id updated_at created_at).include? k}
      end
    end

    def model_name
      self.class.model_name
    end

    def model
      self.class.model
    end

    def disabled? key
      method = ((nested? ? 'nested_' : '')+"#{key}_disabled?").to_sym
      self.class.method_defined?(method) && self.send(method)
    end

    def no_route
      pass
    end

    def record_not_found
      status 404
      ['record not found']
    end

  end
end
