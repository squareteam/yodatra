require 'sinatra/activerecord'

module Yodatra
  class Base < Sinatra::Base
    set(:booted, false)
    set(:booting, true)
    set(:models_directory, 'app/models')
    set(:controllers_directory, 'app/controllers')
  end

  module Boot
    def booting= done
      super
      register Yodatra::Boot
    end

    def self.registered app
      raise "Check it out O'man! You're trying to boot the app [#{app}] which is already booted!" if app.booted
      if app.booting
        # ActiveRecord
        app.register Sinatra::ActiveRecordExtension
        sinatra_ar_version = Gem.loaded_specs['sinatra-activerecord'].version.to_s
        if sinatra_ar_version.gsub('\.', '') <= '123'
          app.set :database_file, "#{Dir.pwd}/config/database.yml"
        else
          app.logger.warn("check out the new version (#{sinatra_ar_version}) of sinatra-activerecord, does it include PR#19 ?") if app.logger
        end

        # Models
        Dir["#{app.models_directory}/**/*.rb"].sort.each do |file_path|
          require File.expand_path file_path
        end

        # Controllers
        Dir["#{app.controllers_directory}/**/*.rb"].sort.each do |file_path|
          require File.expand_path file_path
        end

        app.set :booting, false
        app.set :booted, true
      end
    end
  end
end
