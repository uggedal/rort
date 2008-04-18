require File.join(File.dirname(__FILE__), '..', 'spec_helper')

include Rort

describe Rort::External::Fetchable do

  it 'should be initializated with *as* if existing' do
    External::Artist.as('uggedal').should be_kind_of(External::Fetchable)
  end

  it 'should provide access by block' do
    External::Artist.as('uggedal') do |f|
      f.should be_kind_of(External::Fetchable)
    end
  end

  it 'should not be initlialized on erroneousness requests' do
    External::Artist.as('MrUnknownAndUnfound') do |a|
      a.instance_eval("@doc = fetch('http://nonexistant.none')")
      a.instance_eval('@doc').should be_nil
    end.should be_nil
  end

  it 'should be existing if it has a valid doc' do
    External::Artist.as('uggedal').should be_existing
  end

  it 'should not be existing if it has an invalid doc' do
    External::Artist.as('uggedal') do |a|
      a.instance_eval('@doc = nil')
    end.should_not be_existing
  end

  it 'should return nil with *as* if not existing' do
    External::Artist.as('NonExistantArtist').should be_nil
  end
end

describe Rort::External::Artist do

  it 'should provide access by block' do
    External::Artist.as('uggedal') do |a|
      a.name.should == 'Eivind Uggedal'
    end
  end

  it 'should only fetch the main document once for one object' do
    External::Artist.as('uggedal') do |a|
      should_not_use_http_request do
        a.name.should == 'Eivind Uggedal'
        a.favorites.size.should > 1
      end
    end
  end

  it 'should not be initialized if the artist is not found' do
    External::Artist.as('MrUnknownAndUnfound').should be_nil
  end

  it 'should provide the id of the artist' do
    External::Artist.as('TheMegaphonicThrift').
      id.to_i.should == 70193
  end

  it 'should provide the name of the artist' do
    External::Artist.as('TheMegaphonicThrift').
      name.should == 'The Megaphonic Thrift'
  end

  it 'should provide favorites of the artist' do
    res = External::Artist.as('uggedal').favorites
    res.size.should > 1
    res.each do |fav|
      fav[:slug].should_not be_empty
      fav[:name].should_not be_empty
    end
  end

  it 'should provide an empty array when there are no favorites' do
    External::Artist.as('TheFernets').favorites.size.should be_zero
  end

  it 'should provide fans of the artist' do
    res = External::Artist.as('TheFernets').fans
    res.size.should > 150
    res.each do |fan|
      fan[:slug].should_not be_empty
      fan[:name].should_not be_empty
    end
  end

  it 'should provide an empty array when there are no fans' do
    External::Artist.as('uggedal').fans.size.should be_zero
  end

  it 'should provide songs of the artist' do
    songs = External::Artist.as('TheFernets').songs
    songs.size.should > 5
    songs.each do |song|
      song[:type].should == :song
      song[:time].should < Time.now
      song[:url].should =~ /^http:\/\/\w+/
      song[:title].should_not be_empty
    end
  end

  it 'should provide an empty array when there are no songs' do
    External::Artist.as('uggedal').songs.size.should be_zero
  end

  it 'should provide reviews of the artist' do
    reviews = External::Artist.as('dividizzlDVD').reviews

    reviews.size.should > 5
    reviews.each do |review|
      review[:type].should == :review
      review[:time].should < Time.now
      review[:url].should =~ /^http:\/\/\w+/
      review[:title].should_not be_empty
      review[:reviewer].should_not be_empty
      review[:rating].should < 7
      review[:rating].should > 0
      review[:comment].should_not be_empty
    end
  end

  it 'should provide an empty array when there are no reviews' do
    External::Artist.as('uggedal').reviews.size.should be_zero
  end
end

describe Rort::External::Blog do

  it 'should not be initialized if the artist is non-existent' do
    External::Blog.as('MrNonExistent').should be_nil
  end

  it 'should be initialized if the artist is existing' do
    External::Blog.as('uggedal').should_not be_nil
  end

  it 'could have several blog posts' do
    posts = External::Blog.as('TheFernets').posts
    posts.size.should > 4
    posts.each do |post|
      post[:type].should == :blog
      post[:time].should < Time.now
      post[:url].should =~ /^http:\/\/\w+/
      post[:title].should_not be_empty
    end
  end

  it 'should provide an empty array when there are no blog posts' do
    External::Blog.as('uggedal').posts.size.should be_zero
  end
end

describe Rort::External::Concert do

  it 'should not be initialized if the artist is non-existent' do
    External::Concert.as('MrNonExistent').should be_nil
  end

  it 'should be initialized if the artist is existing' do
    External::Concert.as('uggedal').should_not be_nil
  end

  it 'could have several events' do
    events = External::Concert.as('TheFernets').events
    events.size.should > 15
    events.each do |event|
      event[:type].should == :concert
      event[:time].should < Time.now
      event[:url].should =~ /^http:\/\/\w+/
      event[:title].should_not be_empty
      event[:location].should_not be_empty
      event[:comment].should_not be_nil
    end
  end

  it 'should provide an empty array when there are no events' do
    External::Concert.as('uggedal').events.size.should be_zero
  end
end
