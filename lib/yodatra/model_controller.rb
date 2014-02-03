module Yodatra
  class ModelController < Sinatra::Base

    before do
      content_type 'application/json'
    end

    READ_ALL = :read_all
    get "/*s" do
      no_route if disabled? READ_ALL
      model_name.constantize.all.to_json
    end

    READ_ONE = :read
    get "/*s/:id" do
      no_route if disabled? READ_ONE

      @one = model_name.constantize.find params[:id]
      @one.to_json
    end

    CREATE_ONE = :create
    post "/*s" do
      no_route if disabled? CREATE_ONE

      @one = model_name.constantize.new params

      if @one.save
        @one.to_json
      else
        status 400
        @one.errors.full_messages.to_json
      end
    end

    UPDATE_ONE = :update
    put "/*s/:id" do
      no_route if disabled? UPDATE_ONE

      @one = model_name.constantize.find params[:id]

      if !@one.nil? && @one.update_attributes(params)
        @one.to_json
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
    delete "/*s/:id" do
      no_route if disabled? DELETE_ONE

      @one = model_name.constantize.find params[:id]

      if @one.destroy
        @one.to_json
      else
        status 400
        @one.errors.full_messages.to_json
      end
    end

    private

    def model_params
      params
    end

    def model_name
      self.class.name.gsub(/sController/, '')
    end

    def route_name
      self.send(:model_name).underscore
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