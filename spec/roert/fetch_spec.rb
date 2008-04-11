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
end

describe Roert::Fetch::Artist do

  it 'should provide the artists name' do
    Fetch::Artist.as('uggedal').name.should == 'Eivind Uggedal'
    Fetch::Artist.as('YTO').name.should == 'YTO'
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
end
