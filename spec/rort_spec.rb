require File.join(File.dirname(__FILE__), 'spec_helper')

describe Rort do

  it 'should provide the root path of the application' do
    Rort.root.should == Dir.pwd
  end

  it 'should return a server application instance on start' do
    Rort.start.should be_instance_of(Rort::Server)
    Rort.start.should_not be_nil
  end
end
