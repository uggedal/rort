require File.join(File.dirname(__FILE__), 'spec_helper')

describe Rort do

  it 'should provide the version of the application' do
    Rort::VERSION.should == '0.2.0'
  end

  it 'should provide the root path of the application' do
    Rort.root.should == Dir.pwd
  end

  it 'should provide the number of max activities to be exported' do
    Rort::MAX_ACTIVITIES.should == 10
  end
end
