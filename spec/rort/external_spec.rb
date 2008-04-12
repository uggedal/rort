require File.join(File.dirname(__FILE__), '..', 'spec_helper')

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
end

describe Rort::External::Artist do

  it 'should provide access by block' do
    External::Artist.as('uggedal') do |a|
      a.name.should == 'Eivind Uggedal'
    end
  end

  it 'should only fetch the main document once for one object' do
    External::Artist.as('uggedal') do |a|
      should_not_use_http_request do
        a.name.should == 'Eivind Uggedal'
        a.favorites.size.should == 2
      end
    end
  end

  it 'should not be initialized if the artist is not found' do
    External::Artist.as('MrUnknownAndUnfound').should be_nil
  end

  it 'should provide the name of the artist' do
    External::Artist.as('TheMegaphonicThrift').
      name.should == 'The Megaphonic Thrift'
  end

  it 'should provide the favorites of the artist' do
    res = External::Artist.as('uggedal').favorites
    res.size.should == 2
    res.each do |fav|
      fav.should be_include(:slug)
      fav.should be_include(:name)
    end
  end

  it 'should provide the fans of the artist' do
    res = External::Artist.as('TheFernets').fans
    res.size.should > 150
    res.each do |fan|
      fan.should be_include(:slug)
      fan.should be_include(:name)
    end
  end
end
