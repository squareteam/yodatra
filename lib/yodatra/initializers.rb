require 'sinatra/base'

module Yodatra
  class Base < Sinatra::Base
    set(:init_directory, "config/initializers")
  end

  module Initializers
    def config_directory= path
      super
      register Yodatra::Initializers
    end

    def self.registered app
      Dir["#{app.init_directory}/**/*.rb"].sort.each do |file_path|
        require File.expand_path file_path
      end
    end
  end
end
