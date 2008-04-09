require File.join(File.dirname(__FILE__), '..', 'spec_helper')

include Roert

describe Roert::Fetch, 'artist' do

  it 'should provide the artists name' do
    Fetch::Artist['uggedal'].name.should == 'Eivind Uggedal'
  end

  it 'should provide the artists favorites' do
    Fetch::Artist['uggedal'].favorites.size.should == 2
  end
end
