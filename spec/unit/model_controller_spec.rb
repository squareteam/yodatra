require File.expand_path '../../spec_helper.rb', __FILE__
require 'mocha/setup'
require File.expand_path '../../../lib/yodatra/model_controller.rb', __FILE__

class TestModel
  def all
  end
end

describe 'Model controller' do

  before do
    @any_model = 'TestModel'
    Yodatra::ModelController.any_instance.stubs(:model_name).returns(@any_model)
  end

  it 'should work' do
    get '/test_models'

    last_response.should be_ok
  end

end