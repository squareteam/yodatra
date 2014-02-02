module Yodatra
  class Logger < Sinatra::Base

    configure do
      enable :logging
      filename = File.join(Dir.pwd, 'log', "#{environment}.log")
      file = File.new(filename, 'a+')
      file.sync = true
      use Rack::CommonLogger, file
    end

    #require 'sinatra/logger'
    #register Sinatra::Logger
    # set :logger_level, :debug unless environment == 'production'
    # set the full path to the log file
    # set :logger_log_file, lambda { filename }

  end

end