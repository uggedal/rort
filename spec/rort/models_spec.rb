require File.join(File.dirname(__FILE__), '..', 'spec_helper')

include Rort::Models

describe Artist do

  before(:each) do
    Cache.del('uggedal')
    Cache.del('TheFernets')

    @person = Artist.find_or_fetch('uggedal')
    @artist = Artist.find_or_fetch('TheFernets')
  end

  it 'should be able to find an existing artist' do
    Artist.find_or_fetch('uggedal').name.should == @person.name
  end

  it 'should should return nil for fetching an nonexistent artist' do
    Artist.find_or_fetch('SomeCrazyNonExistentArtist').should be_nil
  end

  it 'should be able to retrieve the slug of an initialized artist' do
    @person.slug.should == 'uggedal'
  end

  it 'should be able to retrieve the name of an initialized artist' do
    @person.name.should == 'Eivind Uggedal'
  end

  it 'could have several favorites' do
    @person.favorites.size > 1
  end

  it 'should be able to fetch the favorites of an initialized artist' do
    @person.favorites.each do |fav|
      fav.should be_instance_of(Artist)
    end
  end

  it 'should be able to fetch the names of favorites on initialization' do
    should_not_use_http_request do
      @person.favorites.each do |fav|
        fav.name.should_not be_nil
      end
    end
  end

  it 'could have several fans' do
    @artist.fans.size > 150
  end

  it 'should be able to fetch the fans of an initialized artist' do
    @artist.fans.each do |fan|
      fan.should be_instance_of(Artist)
    end
  end

  it 'should be able to fetch the names of fans on initialization' do
    should_not_use_http_request do
      @artist.fans.each do |fan|
        fan.name.should_not be_nil
      end
    end
  end

  it 'could have several friends' do
    @person.friends.size.should > 260
  end

end
__END__

  it 'should be serializable' do
    hash = {:id => 1, :slug => 'uggedal', :name => nil}
    JSON.parse(@person.to_json) == hash
  end
