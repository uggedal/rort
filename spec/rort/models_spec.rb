require File.join(File.dirname(__FILE__), '..', 'spec_helper')

include Rort::Models

describe Artist do

  before(:each) do
    DataMapper::Persistence.auto_migrate!
    @artist = Artist.find_or_fetch('uggedal')
  end

  it 'should be findable' do
    found = Artist.first('uggedal')
    @artist.should == found
  end

  it 'could have and belong to many favorites' do
    @artist.favorites.size > 1
  end

  it 'could have and belong to many fans' do
    Artist.find_or_fetch('TheFernets').fans.size.should > 150
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

  it 'should be able to fetch the fans of an initialized artist' do
    artist = Artist.find_or_fetch('TheFernets')
    artist.fans.each do |fan|
      fan.should be_instance_of(Artist)
    end
  end

  it 'should be able to fetch the names of favorites on initialization' do
    @artist.favorites.size.should > 1
    should_not_use_http_request do
      @artist.favorites.each do |fav|
        fav.name.should_not be_nil
      end
    end
  end

  it 'should be able to fetch the names of fans on initialization' do
    artist = Artist.find_or_fetch('TheFernets')
    artist.fans.size.should > 150
    artist.fans.each do |fan|

      fan.slug.should_not be_nil
      if fan.name == nil
        puts fan.slug
      end
      fan.name.should_not be_nil
    end
  end

  it 'could have several friends' do
    @artist.friends.size.should > 260
  end
end
