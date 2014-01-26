require 'sinatra/base'
require 'sinatra/reloader'

require File.expand_path  '../boot', __FILE__
require File.expand_path  '../initializers', __FILE__
require File.expand_path  '../logger', __FILE__

module Yodatra
  class Base < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end
    register Boot
    register Initializers
    register Logger
  end
end