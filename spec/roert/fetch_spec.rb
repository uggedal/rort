require File.join(File.dirname(__FILE__), '..', 'spec_helper')

include Roert::Fetch

describe Roert::Fetch, 'artist' do

  before(:all) do
    @artist = artist('uggedal')
  end

  it 'should provide the artists name' do
    @artist[:name].should == 'Eivind Uggedal'
  end

  it 'should provide the artists favorites' do
    @artist[:favorites].size.should == 2
  end
end
