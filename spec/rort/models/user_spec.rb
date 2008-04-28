require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

include Rort::Models

describe User do

  before(:each) do
    @user = User.new('uggedal')
  end

  it 'should be able to retrieve external resource of an initialized user' do
    @user.external.should be_instance_of(Rort::External::Artist)
  end

  it 'should be able to retrieve the slug of an initialized user' do
    @user.slug.should == 'uggedal'
  end

  it 'should be able to retrieve the name of an initialized user' do
    @user.name.should == 'Eivind Uggedal'
  end
end
