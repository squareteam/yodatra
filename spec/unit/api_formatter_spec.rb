require File.expand_path '../../spec_helper.rb', __FILE__

describe Yodatra::ApiFormatter do
  let(:app) { proc{[200,{},['Hello, world.']]} }

  before do
    @stack = Yodatra::ApiFormatter.new(app, &bloc)
    @request = Rack::MockRequest.new(@stack)
  end

  context 'with a unity bloc' do
    let(:bloc) { proc{ |s,h,r| [s,h,r] } }

    it 'transforms the response with the given block' do
      response = @request.get('/')
      expect(response.body).to eq 'Hello, world.'
    end
  end

  context 'with an object wrapper bloc' do
    let(:bloc) do
      proc do |s,h,r|
        transformed = r.map{ |rr| {data: rr}.to_json }
        [s,h,transformed]
      end
    end

    it 'transforms the response with the given block' do
      response = @request.get('/')
      expect(JSON.parse(response.body)['data']).to eq 'Hello, world.'
    end
  end
end
