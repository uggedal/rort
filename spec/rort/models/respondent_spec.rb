require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

include Rort::Models

describe Respondent do

  before(:each) do
    Respondent.create_table!
    @respondent = Respondent.create(:email => 'eu@redflavor.com')
  end

  it 'should be able to be created' do
    Respondent.create(:email => 'unique@email.org').should_not be_nil
  end

  it 'should be able to be retrieved' do
    Respondent.find(:email => 'eu@redflavor.com').should == @respondent
  end

  it 'should be retrieved if existing or created if non-existing' do
    Respondent.find_or_create(:email => 'eu@redflavor.com').should_not be_nil
    Respondent.find_or_create(:email => 'unique@email.org').should_not be_nil
  end

  it 'should not be stored with an invalid email' do
    Respondent.create(:email => 'invalid.org').errors.should_not be_empty
    Respondent.create(:email => 'invalid@email').errors.should_not be_empty
    Respondent.create(:email => '').errors.should_not be_empty
  end

  it 'should store time of creation' do
    @respondent.created_at.should > Time.now - 5
    @respondent.created_at.should < Time.now
  end

  it 'should store a respondent group different than previous record' do
    second = Respondent.create(:email => 'unique@email.org')

    @respondent.group.should_not be_empty
    second.group.should_not be_empty

    @respondent.group.should_not == second.group
  end

  it 'should have a default requests cound of zero' do
    @respondent.requests.should == 0
  end

  it 'should incremented request count on requests' do
    Respondent.increment('eu@redflavor.com', 'uggedal').requests.should == 1
    Respondent.increment('eu@redflavor.com', 'uggedal').requests.should == 2
    Respondent.increment('eu@redflavor.com', 'uggedal').requests.should == 3
  end
end
