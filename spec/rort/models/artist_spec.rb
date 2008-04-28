require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

include Rort::Models

describe Artist do

  before(:each) do
    Rort::Cache.del('TheFernets')
    @artist = Artist.find_or_fetch('TheFernets')
  end

  it 'should be able to find an existing artist' do
    Artist.find_or_fetch('TheFernets').name.should == @artist.name
  end

  it 'should should return nil for fetching an nonexistent person' do
    Artist.find_or_fetch('SomeCrazyNonExistentArtist').should be_nil
  end

  it 'could have blog posts' do
    @artist.blog.posts.size.should > 10
  end

  it 'could have songs' do
    @artist.songs.size.should > 5
  end

  it 'could have concert events' do
    @artist.concert.events.size.should > 40
  end

  it 'could have song reviews' do
    @artist.reviews.size.should > 1
  end

  it 'should provide a sorted list of activities' do
    activities = @artist.activities
    activities.size.should > 1
    activities.first[:datetime].should > activities.last[:datetime]
  end
end
