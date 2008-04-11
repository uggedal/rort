require File.join(File.dirname(__FILE__), '..', 'spec_helper')

include Roert

describe Roert::Fetch::Fetchable do

  it 'should provide initialization with *as*' do
    Fetch::Fetchable.new.class.should == Fetch::Fetchable.as.class
  end

  it 'should provide access by block' do
    Fetch::Fetchable.new do |f|
      f.class.should == Fetch::Fetchable
    end
  end

  it 'should not be initlialized on erroneousness requests' do
    Fetch::Artist.as('MrUnknownAndUnfound') do |a|
      a.instance_eval("@doc = fetch('http://nonexistant.none')")
      a.instance_eval('@doc').should be_nil
    end.should_not be_existing
  end

  it 'should be existing if it has a valid doc' do
    Fetch::Artist.as('uggedal').should be_existing
  end

  it 'should not be existing if it has an invalid doc' do
    Fetch::Artist.as('uggedal') do |a|
      a.instance_eval('@doc = nil')
    end.should_not be_existing
  end
end

describe Roert::Fetch::Artist do

  it 'should provide the artists name' do
    Fetch::Artist.as('uggedal').name.should == 'Eivind Uggedal'
    Fetch::Artist.as('YTO').name.should == 'YTO'
    Fetch::Artist.as('TheMegaphonicThrift').
      name.should == 'The Megaphonic Thrift'
  end

  it 'should provide the artists favorites' do
    Fetch::Artist.as('uggedal').favorites.size.should == 2
  end

  it 'should provide access by block' do
    Fetch::Artist.as('uggedal') do |a|
      a.name.should == 'Eivind Uggedal'
    end
  end

  it 'should only fetch the main document once for one object' do
    Fetch::Artist.as('uggedal') do |a|
      should_not_use_http_request do
        a.name.should == 'Eivind Uggedal'
        a.favorites.size.should == 2
      end
    end
  end

  it 'should not be existing if the artist is not found' do
    Fetch::Artist.as('MrUnknownAndUnfound').should_not be_existing
  end
end
