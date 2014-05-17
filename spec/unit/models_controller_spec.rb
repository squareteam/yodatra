require File.expand_path '../../spec_helper.rb', __FILE__
require File.expand_path '../../data/model.rb', __FILE__

describe 'Model controller' do

  before do
    @errors = ['error']
    allow_any_instance_of(Array).to receive(:full_messages).and_return(@errors)
  end

  describe 'Getting a collection of the Model' do
    context 'default' do
      it 'should have a GET all route' do
        get '/models'

        last_response.should be_ok
        expect(last_response.body).to eq(Model::ALL.map{|e| {:data => e} }.to_json)
      end
    end
    context 'nested' do
      it 'should have a GET all route' do
        get '/models/1/models'

        last_response.should be_ok
        expect(last_response.body).to eq(Model::ALL.map{|e| {:data => e} }.to_json)
      end
    end
    context 'forced GET all route disabled' do
      before do
        class Yodatra::ModelsController
          disable :read_all
        end
      end
      it 'should fail with no route available' do
        get '/models'

        last_response.should_not be_ok
      end
    end
  end
  describe 'getting an specific Model instance' do
    it 'should have a GET one route' do
      get '/models/2'

      last_response.should be_ok
      expect(last_response.body).to eq({ :data => 'c'}.to_json)
    end
    context 'forced GET one route disabled' do
      before do
        class Yodatra::ModelsController
          disable :read
        end
      end
      it 'should fail with no route available' do
        get '/models/1'

        last_response.should_not be_ok
      end
    end
  end
  describe 'creating a Model instance' do
    context 'with correct model params' do
      it 'creates an instance, saves it and succeed' do
        expect{
          post '/models', {:data => 'd'}
        }.to change(Model::ALL, :length).by(1)

        last_response.should be_ok
      end
    end
    context 'with incorrect params' do
      it 'does not create an instance and fails' do
        expect{
          post '/models', {}
        }.to change(Model::ALL, :length).by(0)

        last_response.should_not be_ok
        expect(last_response.body).to eq(@errors.to_json)
      end
    end
    context 'when the creation route is disabled' do
      before do
        class Yodatra::ModelsController
          disable :create
        end
      end
      it 'should fail with no route available' do
        post '/models', {:data => 'd'}

        last_response.should_not be_ok
      end
    end
  end
  describe 'updating a Model instance' do
    context 'that does not exist' do
      it 'replies with an error' do
        expect{
          put '/models/21', {:data => 'e'}
        }.to change(Model::ALL, :length).by(0)

        last_response.should_not be_ok
        expect(last_response.body).to eq(['record not found'].to_json)
      end
    end
    context 'that already exist' do
      context 'with correct model params' do
        it 'updates the model, saves it and succeed' do
          expect{
            put '/models/2', {:data => 'e'}
          }.to change(Model::ALL, :length).by(0)

          last_response.should be_ok
          expect(last_response.body).to eq({ :data => 'e'}.to_json)
          expect(Model.find(2).to_json).to eq({ :data => 'e'}.to_json)
        end
      end
      context 'with incorrect params' do
        it 'replies with an error message' do
          expect{
            put '/models/2', {:data => 321}
          }.to change(Model::ALL, :length).by(0)

          last_response.should_not be_ok
          expect(last_response.body).to eq(@errors.to_json)
        end
      end
      context 'when the updating route is disabled' do
        before do
          class Yodatra::ModelsController
            disable :update
          end
        end
        it 'should fail with no route available' do
          put '/models', {:data => 'd'}

          last_response.should_not be_ok
        end
      end
    end
  end
  describe 'deleting a Model instance' do
    context 'targeting an existing instance' do
      it 'deletes the instance and succeed' do
        expect{
          delete '/models/1'
        }.to change(Model::ALL, :length).by(-1)

        last_response.should be_ok
      end
    end
    context 'targeting an existing instance but deletion fails' do
      before do
        allow_any_instance_of(Model).to receive(:destroy).and_return(false)
      end
      it 'should not delete the instance and fails' do
        expect{
          delete '/models/1/models/1'
        }.to change(Model::ALL, :length).by(0)

        last_response.should_not be_ok
        expect(last_response.body).to eq(@errors.to_json)
      end
    end
    context 'targeting a not existing instance' do
      it 'does not delete any instance and fails' do
        expect{
          delete '/models/6'
        }.to change(Model::ALL, :length).by(0)

        last_response.should_not be_ok
      end
    end
    context 'when the deletion route is disabled' do
      before do
        class Yodatra::ModelsController
          disable :delete
        end
      end
      it 'should fail with no route available' do
        delete '/models/2'

        last_response.should_not be_ok
      end
    end
  end

  describe 'non existing models' do
    context 'in nested routes' do
      context 'with wrong route name' do
        before do
          class Yodatra::ModelsController
            method = "read_all_disabled?".to_sym
            undef_method method if method_defined? method
          end
        end
        it 'fails with a record not found message' do
           get '/modeels/1/models'

           last_response.should_not be_ok
           expect(last_response.body).to eq(['record not found'].to_json)
        end
      end
      context 'with non existant parent model' do
        it 'fails with a record not found message' do
          get '/models/123/models'

          last_response.should_not be_ok
          expect(last_response.body).to eq(['record not found'].to_json)
        end
      end
    end

  end

end