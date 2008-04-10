require File.join(File.dirname(__FILE__), '..', 'spec_helper')

include Roert::Models

describe Artist do

  before(:each) do
    DataMapper::Persistence.auto_migrate!
    @artist = Artist.create(:slug => 'uggedal')
  end

  it 'should be createable' do
    a = Artist.create(:slug => 'supersuper')
    a.should_not be_new_record
  end

  it 'should be updateable' do
    @artist.name = 'Eivind Uggedal'
    @artist.should be_dirty
    @artist.save
    @artist.should_not be_dirty
  end

  it 'should be findable' do
    found = Artist.first(:slug => 'uggedal')
    @artist.should == found
  end

  it 'could have and belong to many favorites' do
    a = Artist.create(:slug => 'artist_a')
    b = Artist.create(:slug => 'artist_b')
    c = Artist.create(:slug => 'artist_c')

    @artist.update_attributes(:favorites => [a, b, c])
    @artist.favorites.first.should == a

    a.favorites << @artist
    a.favorites.first.should == @artist
  end

  it 'should be serializable' do
    hash = {:id => 1, :slug => 'uggedal', :name => nil}
    JSON.parse(@artist.to_json) == hash
  end

end
