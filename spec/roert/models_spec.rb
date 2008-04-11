require File.join(File.dirname(__FILE__), '..', 'spec_helper')

include Roert::Models

describe Artist do

  before(:each) do
    DataMapper::Persistence.auto_migrate!
    @artist = Artist.find_or_fetch('uggedal')
  end

  it 'should be createable' do
    a = Artist.create(:slug => 'supersuper')
    a.should_not be_new_record
  end

  it 'should be updateable' do
    @artist.slug = 'eivind'
    @artist.should be_dirty
    @artist.save
    @artist.should_not be_dirty
  end

  it 'should be findable' do
    found = Artist.first('uggedal')
    @artist.should == found
  end

  it 'could have and belong to many favorites' do
    @artist.favorites.last.name.should == '-The Fernets-'
  end

  it 'should be serializable' do
    hash = {:id => 1, :slug => 'uggedal', :name => nil}
    JSON.parse(@artist.to_json) == hash
  end

  it 'should find an existing artist' do
    Artist.find_or_fetch('uggedal').should == @artist
  end

  it 'should fetch an unfound artist' do
    fetched = Artist.find_or_fetch('YTO')
    fetched.should_not be_new_record
  end

  it 'should should return nil for fetching an nonexistent artist' do
    Artist.find_or_fetch('SomeCrazyNonExistentArtist').should be_nil
  end

  it 'should provide access to external fetched data about itself' do
    @artist.external.name.should == 'Eivind Uggedal'
  end

  it 'should be able to fetch the name of an initialized artist' do
    @artist.name.should == 'Eivind Uggedal'
  end

  it 'should be able to fetch the favorites of an initialized artist' do
    @artist.favorites.each do |fav|
      fav.should be_instance_of(Artist)
    end
  end

  it 'should be able to fetch the names of favorites on initialization' do
    @artist.favorites.size.should == 2
    should_not_use_http_request do
      @artist.favorites.each do |fav|
        fav.name.should_not be_nil
      end
    end
  end
end
