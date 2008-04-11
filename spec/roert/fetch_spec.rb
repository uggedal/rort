require File.join(File.dirname(__FILE__), '..', 'spec_helper')

include Roert

describe Roert::Fetch::Fetchable do

  it 'should be initializated with *as* if existing' do
    Fetch::Artist.as('uggedal').should be_kind_of(Fetch::Fetchable)
  end

  it 'should provide access by block' do
    Fetch::Artist.as('uggedal') do |f|
      f.should be_kind_of(Fetch::Fetchable)
    end
  end

  it 'should not be initlialized on erroneousness requests' do
    Fetch::Artist.as('MrUnknownAndUnfound') do |a|
      a.instance_eval("@doc = fetch('http://nonexistant.none')")
      a.instance_eval('@doc').should be_nil
    end.should be_nil
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

  it 'should not be initialized if the artist is not found' do
    Fetch::Artist.as('MrUnknownAndUnfound').should be_nil
  end
end
