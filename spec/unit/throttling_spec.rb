require File.expand_path '../../spec_helper.rb', __FILE__

describe 'Throttling middleware' do
  context 'When redis gem is not installed' do
    it 'raises an exception when required' do
      expect{
        require 'yodatra/throttling'
      }.to raise_error LoadError, /gem install 'redis'/
    end
  end

  #context 'When redis is installed' do
  #  it 'does not raise an exception when required' do
  #    allow_any_instance_of(Kernel).to receive(:require).and_call_original
  #    allow_any_instance_of(Kernel).to receive(:require).with('redis').and_return(true)
  #
  #    expect{
  #      require 'yodatra/throttling'
  #    }.not_to raise_error
  #  end
  #end
end
