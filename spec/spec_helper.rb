ENV['RACK_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start
require 'coveralls'
Coveralls.wear!
require 'rack/test'
require 'rspec'

require File.expand_path '../../lib/yodatra.rb', __FILE__
require File.expand_path '../../lib/yodatra/model_controller.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app
    Sinatra.new {
      use Yodatra::Base
      use Yodatra::ModelController
    }
  end
end

RSpec.configure do |c|
  c.include RSpecMixin
end
