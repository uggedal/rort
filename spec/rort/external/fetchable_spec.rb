require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

include Rort

describe Rort::External::Fetchable do

  it 'should be initializated with *as* if existing' do
    External::Artist.as('uggedal').should be_kind_of(External::Fetchable)
  end

  it 'should provide access by block' do
    External::Artist.as('uggedal') do |f|
      f.should be_kind_of(External::Fetchable)
    end
  end

  it 'should not be initlialized on erroneousness requests' do
    External::Artist.as('MrUnknownAndUnfound') do |a|
      a.instance_eval("@doc = fetch('http://nonexistant.none')")
      a.instance_eval('@doc').should be_nil
    end.should be_nil
  end

  it 'should be existing if it has a valid doc' do
    External::Artist.as('uggedal').should be_existing
  end

  it 'should not be existing if it has an invalid doc' do
    External::Artist.as('uggedal') do |a|
      a.instance_eval('@doc = nil')
    end.should_not be_existing
  end

  it 'should return nil with *as* if not existing' do
    External::Artist.as('NonExistantArtist').should be_nil
  end

  it 'should provide an url for a given path' do
    External::Fetchable.url('path').should == 'http://www11.nrk.no/urort/path'
  end
end
