require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Rort::Cache do

  before(:each) do
    Rort::Cache.del('one')
    Rort::Cache.del('two')

    @one = [1, 2, 3, :a, :b, :c, {:a => 1, :b => 2}]
    @two = [3, 2, 1, :c, :b, :a, {:b => 2, :a => 1}]

    Rort::Cache['one'] = @one
    Rort::Cache['two'] = @two
  end

  it 'should be able to retrieve a single record from the cache' do
    Rort::Cache['one'].should == @one
  end

  it 'should be able to retrieve several records from the cache' do
    res = Rort::Cache[['one', 'two']]
    res['one'].should == @one
    res['two'].should == @two
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
    Rort::Cache['one'].should_not be_nil
    Rort::Cache.del('one').should =~ /^DELETED/
    Rort::Cache['one'].should be_nil
  end

end
