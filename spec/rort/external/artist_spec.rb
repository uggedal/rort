require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

include Rort

describe Rort::External::Artist do

  it 'should provide access by block' do
    External::Artist.as('uggedal') do |a|
      a.name.should == 'Eivind Uggedal'
    end
  end

  it 'should only fetch the main document once for one object' do
    External::Artist.as('uggedal') do |a|
      reqs = $http_requests

      a.name.should == 'Eivind Uggedal'
      a.favorites.size.should > 1

      reqs.should == $http_requests
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

  it 'should provide the path of the artist' do
    External::Artist.as('uggedal').path.should == 'Artist/uggedal'
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
      song[:datetime].should < Time.now
      song[:date].should_not be_empty
      song[:time].should_not be_empty
      song[:url].should =~ /^http:\/\/\w+/
      song[:title].should_not be_empty
      song[:artist].should_not be_empty
      song[:artist_url].should =~ /^http:\/\/\w+/
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
      review[:datetime].should < Time.now
      review[:date].should_not be_empty
      review[:time].should_not be_empty
      review[:url].should =~ /^http:\/\/\w+/
      review[:title].should_not be_empty
      review[:artist].should_not be_empty
      review[:artist_url].should =~ /^http:\/\/\w+/
      review[:reviewer].should_not be_empty
      review[:reviewer_url].should =~ /^http:\/\/\w+/
      review[:rating].should < 2
      review[:rating].should > -1
      review[:comment].should_not be_empty
    end
  end

  it 'should provide an empty array when there are no reviews' do
    External::Artist.as('uggedal').reviews.size.should be_zero
  end
end
