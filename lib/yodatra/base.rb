require 'sinatra/base'
require File.expand_path  '../boot', __FILE__
require File.expand_path  '../initializers', __FILE__


module Yodatra
  class Base < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
    end

    register Sinatra::Boot
    register Sinatra::Initializers
  end
end