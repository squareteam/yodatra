require 'sinatra/base'

module Yodatra
  class Base < Sinatra::Base
    set(:config_directory, "config/initializers")
  end

  module Initializers
    def config_directory= path
      super
      register Yodatra::Initializers
    end

    def self.registered app
      Dir["#{app.config_directory}/**/*.rb"].sort.each do |file_path|
        require File.expand_path file_path
      end
    end
  end
end
