require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

include Rort

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
      post[:datetime].should < Time.now
      post[:date].should_not be_empty
      post[:time].should_not be_empty
      post[:url].should =~ /^http:\/\/\w+/
      post[:title].should_not be_empty
      post[:author].should_not be_empty
      post[:author_url].should =~ /^http:\/\/\w+/
    end
  end

  it 'should provide an empty array when there are no blog posts' do
    External::Blog.as('uggedal').posts.size.should be_zero
  end
end
