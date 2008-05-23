require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

include Rort::Models

describe Person do

  before(:each) do
    @person = Person.fetch('uggedal')
  end

  it 'should be able to find an existing user' do
    Person.fetch('uggedal').name.should == @person.name
  end

  it 'should should return nil for fetching an nonexistent person' do
    Person.fetch('SomeCrazyNonExistentArtist').should be_nil
  end

  it 'should be able to fetch the favorites of an initialized artist' do
    should_not_use_http_request do
      @person.favorites.each do |fav|
        fav.name.should_not be_nil
      end
    end
  end

  it 'should collect a sorted list of recent activity of all favorites' do
    activities = @person.favorite_activities
    activities.size.should > 1
    activities.size.should <= Rort::MAX_ACTIVITIES
    activities.first[:datetime].should > activities.last[:datetime]
  end


  it 'should only collect cached activities or one uncached' do
    person = Person.fetch('Nikeyy')
    person.favorites.each do |fav|
      Rort::Cache.del(fav.slug + ':activities')
    end

    Rort::Queue.clean
    Rort::Queue.shift.should be_nil

    activities = person.favorite_activities

    Rort::Queue.shift.should_not be_empty

    person.favorites.each do |fav|
      Rort::Cache.del(fav.slug + ':activities')
    end
  end
end
