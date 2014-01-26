module Yodatra
  module Logger
    def self.registered(app)
      filename = File.join(Dir.pwd, 'log', "#{app.environment}.log")
      app.configure do
        app.enable :logging
        file = File.new(filename, 'a+')
        file.sync = true
        app.use Rack::CommonLogger, file
      end
      require 'sinatra/logger'
      app.register Sinatra::Logger
      app.set :logger_level, :debug unless app.environment == 'production'
      # set the full path to the log file
      app.set :logger_log_file, lambda { filename }

    end #/ self.registered
  end
end