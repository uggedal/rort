require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

include Rort::Models

describe Requestor do

  before(:each) do
    Requestor.create_table!
    @requestor = Requestor.create(:slug => 'uggedal', :group => 'control')
  end

  it 'should be able to be created' do
    Requestor.create(:slug => 'SSlug', :group => 'control').should_not be_nil
  end

  it 'should be able to be retrieved' do
    Requestor.find(:slug => 'uggedal').should == @requestor
  end

  it 'should have a default requests cound of zero' do
    @requestor.requests.should == 0
  end

  it 'should be incremented if existing or created if non-existing' do
    Requestor.increment_or_create('control', 'uggedal').requests.should == 1
    Requestor.increment_or_create('control', 'uggedal').requests.should == 2
    Requestor.increment_or_create('control', 'uggedal').requests.should == 3

    Requestor.increment_or_create('experiment', 'SSlug').requests.should == 1
    Requestor.increment_or_create('experiment', 'SSlug').requests.should == 2
    Requestor.increment_or_create('experiment', 'SSlug').requests.should == 3
  end

  it 'should store time of creation' do
    @requestor.created_at.should > Time.now - 5
    @requestor.created_at.should < Time.now
  end
end
