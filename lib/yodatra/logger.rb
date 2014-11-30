require "clogger"

module Yodatra
  class Logger < Sinatra::Base

    configure do
      set :logging, true
      set :root, Dir.pwd
    end
    configure :development, :production do
      path ||= File.join(Dir.pwd, 'log', "#{environment}.log")
      format ||= :Combined
      file_stdout = File.new(path, 'a+')
      file_stdout.sync = true
      use Clogger, :logger => file_stdout, :format => format
    end

  end
end
