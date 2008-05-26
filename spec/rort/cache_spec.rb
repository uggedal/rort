require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Rort::Cache do

  before(:each) do
    Rort::Cache.del('uggedal')
    Rort::Cache.del('TheFernets')

    @person = Rort::Models::Artist.find_or_fetch('uggedal')
    @artist = Rort::Models::Artist.find_or_fetch('TheFernets')
  end

  it 'should be able to retrieve a single record from the cache' do
    Rort::Cache[Rort::Models::Artist.key('uggedal')].name.
      should == @person.name
  end

  it 'should be able to retrieve several records from the cache' do
    keys = [Rort::Models::Artist.key('uggedal'),
            Rort::Models::Artist.key('TheFernets')]
    res = Rort::Cache[keys]
    res[keys.first].name.should == @person.name
    res[keys.last].name.should == @artist.name
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
    key = Rort::Models::Artist.key(@person.slug)
    Rort::Cache[key].should_not be_nil
    Rort::Cache.del(key).should =~ /^DELETED/
    Rort::Cache[key].should be_nil
  end

end
