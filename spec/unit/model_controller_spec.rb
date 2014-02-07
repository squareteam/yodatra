require File.expand_path '../../spec_helper.rb', __FILE__

# Mock model constructed for the tests
class TestModel
  ALL = %w(a b c)
  class << self
    def all; ALL.map{ |e| TestModel.new({:data=> e }) }; end
    def find(id); TestModel.new({:data => ALL[id.to_i]}); end
  end
  def initialize(param); @data = param[:data]; end
  def save
    if @data.is_a? String
      ALL.push(@data)
      true
    else
      false
    end
  end
  def destroy
    if ALL.include? @data
      ALL.delete @data
      true
    else
      false
    end
  end
  def errors; []; end
end

describe 'Model controller' do
  before do
    @any_model = 'TestModel'
    @errors = ['error']
    allow_any_instance_of(Yodatra::ModelController).to receive(:model_name).and_return(@any_model)
    allow_any_instance_of(Array).to receive(:full_messages).and_return(@errors)
  end

  describe 'Getting a collection of the Model' do
    context 'default' do
      it 'should have a GET all route' do
        get '/test_models'

        last_response.should be_ok
        expect(last_response.body).to eq(TestModel::ALL.map{|e| {:data => e} }.to_json)
      end
    end
    context 'forced GET all route disabled' do
      before do
        class Yodatra::ModelController
          disable :read_all
        end
      end
      it 'should fail with no route available' do
        get '/test_models'

        last_response.should_not be_ok
      end
    end
  end
  describe 'getting an specific Model instance' do
    it 'should have a GET one route' do
      get '/test_models/2'

      last_response.should be_ok
      expect(last_response.body).to eq({ :data => 'c'}.to_json)
    end
    context 'forced GET one route disabled' do
      before do
        class Yodatra::ModelController
          disable :read
        end
      end
      it 'should fail with no route available' do
        get '/test_models/1'

        last_response.should_not be_ok
      end
    end
  end
  describe 'creating a Model instance' do
    context 'with correct model params' do
      it 'adds creates an instance, saves it and succeed' do
        expect{
          post '/test_models', {:data => 'd'}
        }.to change(TestModel::ALL, :length).by(1)

        last_response.should be_ok
      end
    end
    context 'with incorrect params' do
      it 'doesn t create an instance and fails' do
        expect{
          post '/test_models', {}
        }.to change(TestModel::ALL, :length).by(0)

        last_response.should_not be_ok
        expect(last_response.body).to eq(@errors.to_json)
      end
    end
    context 'when the creation route is disabled' do
      before do
        class Yodatra::ModelController
          disable :create
        end
      end
      it 'should fail with no route available' do
        post '/test_models', {:data => 'd'}

        last_response.should_not be_ok
      end
    end
  end
  describe 'deleting a Model instance' do
    context 'targeting an existing instance' do
      it 'deletes the instance and succeed' do
        expect{
          delete '/test_models/1'
        }.to change(TestModel::ALL, :length).by(-1)

        last_response.should be_ok
      end
    end
    context 'targeting a not existing instance' do
      it 'does not delete any instance and fails' do
        expect{
          delete '/test_models/6'
        }.to change(TestModel::ALL, :length).by(0)

        last_response.should_not be_ok
      end
    end
    context 'when the deletion route is disabled' do
      before do
        class Yodatra::ModelController
          disable :delete
        end
      end
      it 'should fail with no route available' do
        delete '/test_models/2'

        last_response.should_not be_ok
      end
    end
  end

end