require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Rort::Cache do

  before(:each) do
    Rort::Cache.del('uggedal')
    Rort::Cache.del('TheFernets')

    @person = Artist.find_or_fetch('uggedal')
    @artist = Artist.find_or_fetch('TheFernets')
  end

  it 'should be able to retrieve a single record from the cache' do
    Rort::Cache['uggedal'].name.should == @person.name
  end

  it 'should be able to retrieve several records from the cache' do
    res = Rort::Cache[%w(uggedal TheFernets)]
    res['uggedal'].name.should == @person.name
    res['TheFernets'].name.should == @artist.name
  end

  it 'should provide nil for non-existant records' do
    Rort::Cache['NonExistant'].should be_nil
  end

  it 'should be able to set a new record in the cache' do
    hash = {:key => 'superduper', :name => 'wow'}
    Rort::Cache.del(hash[:key])
    Rort::Cache[hash[:key]].should be_nil
    Rort::Cache[hash[:key]] = hash
    Rort::Cache[hash[:key]][:name].should == hash[:name]
  end

  it 'should be able to delete a record in the cache' do
    Rort::Cache[@person.slug].should_not be_nil
    Rort::Cache.del(@person.slug).should =~ /^DELETED/
    Rort::Cache[@person.slug].should be_nil
  end

end
