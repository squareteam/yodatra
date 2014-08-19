ENV['RACK_ENV'] ||= 'test'
require 'simplecov'
SimpleCov.start
require 'coveralls'
Coveralls.wear!
require 'rack/test'
require 'rspec'

require File.expand_path '../../lib/yodatra.rb', __FILE__
require File.expand_path '../../lib/yodatra/api_formatter.rb', __FILE__
require File.expand_path '../../lib/yodatra/models_controller.rb', __FILE__
require File.expand_path '../data/ar_models_controller.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app
    Sinatra.new {
      use Yodatra::Base
      use Yodatra::ApiFormatter
      use Yodatra::ModelsController
      use ArModelsController
    }
  end
end

RSpec.configure do |c|
  c.include RSpecMixin
end
