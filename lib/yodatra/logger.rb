module Yodatra
  class Logger < Sinatra::Base

    configure do
      set :logging, true
      set :root, Dir.pwd
    end
    configure :development, :production do
      filename_stdout = File.join(root, 'log', "#{environment}.log")
      filename_stderr = File.join(root, 'log', "#{environment}.err.log")
      file_stdout = File.new(filename_stdout, 'a+')
      file_stderr = File.new(filename_stderr, 'a+')
      file_stdout.sync = true
      file_stderr.sync = true
      use Rack::CommonLogger, file_stdout
      $stderr.reopen(file_stderr)
    end

  end

end