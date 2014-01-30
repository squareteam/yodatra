require 'sinatra/logger'

module Yodatra
  class Logger < Sinatra::Base

    def call(env)
      env['yodatra.logger'] ? @app.call(env) : super
    end

    superclass.class_eval do
      alias call_without_check call unless method_defined? :call_without_check
      def call(env)
        env['sinatra.commonlogger'] = true
        call_without_check(env)
      end
    end

    filename = File.join(Dir.pwd, 'log', "#{environment}.log")

    unless @env['yodatra.logger']
      configure do
        enable :logging
        file = File.new(filename, 'a+')
        file.sync = true
        use Rack::CommonLogger, file
        env['yodatra.logger'] = true
      end
    end

    register Sinatra::Logger
    app.set :logger_level, :debug unless app.environment == 'production'
    # set the full path to the log file
    app.set :logger_log_file, lambda { filename }

  end
end