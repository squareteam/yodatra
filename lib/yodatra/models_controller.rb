module Yodatra
  class ModelsController < Sinatra::Base

    before do
      content_type 'application/json'
    end

    READ_ALL = :read_all
    get "/*" do
      pass unless involved?
      no_route if disabled? READ_ALL
      model_name.constantize.all.as_json(read_scope).to_json
    end

    READ_ONE = :read
    get "/*/:id" do
      pass unless involved?
      no_route if disabled? READ_ONE

      @one = model_name.constantize.find params[:id]
      @one.as_json(read_scope).to_json
    end

    CREATE_ONE = :create
    post "/*" do
      pass unless involved?
      no_route if disabled? CREATE_ONE

      hash = self.send("#{model_name.underscore}_params".to_sym)
      @one = model_name.constantize.new hash

      if @one.save
        @one.as_json(read_scope).to_json
      else
        status 400
        @one.errors.full_messages.to_json
      end
    end

    UPDATE_ONE = :update
    put "/*/:id" do
      pass unless involved?
      no_route if disabled? UPDATE_ONE

      @one = model_name.constantize.find params[:id]

      if !@one.nil? && @one.update_attributes(params)
        @one.as_json(read_scope).to_json
      else
        status 400
        if !@one.nil?
          @one.errors.full_messages.to_json
        else
          ['record not found'].to_json
        end
      end
    end

    DELETE_ONE = :delete
    delete "/*/:id" do
      pass unless involved?
      no_route if disabled? DELETE_ONE

      @one = model_name.constantize.find params[:id]

      if @one.destroy
        @one.as_json(read_scope).to_json
      else
        status 400
        @one.errors.full_messages.to_json
      end
    end

    class << self
      def model_name
        self.name.split('::').last.gsub(/sController/, '')
      end

      def route_name
        self.model_name.underscore
      end
    end

    private

    def involved?
      params[:splat].first == model_name.downcase
    end

    # read_scope defaults to all attrs of the model
    def read_scope
      {}
    end

    # create/update scope defaults to all data given in the POST/PUT
    def method_missing(name, *args)
      if name.to_s == "#{model_name.underscore}_params"
        return params.reject{|k,v| %w(splat captures).include? k}
      end
    end

    def model_name
      self.class.model_name
    end

    def route_name
      self.class.route_name
    end

    def disabled? key
      params[:splat].first != route_name || self.class.method_defined?(key) && self.send(key)
    end

    def no_route
      pass
    end

    class << self
      def disable(*opts)
        opts.each do |key|
          undef_method(key) if method_defined? key
          define_method(key, Proc.new {|| true})
        end
      end
    end

  end
end