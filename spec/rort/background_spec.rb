require File.join(File.dirname(__FILE__), '..', 'spec_helper')

require File.join(Rort.root, 'lib', 'rort', 'background')

describe Rort::Background do
  include Rort::Background

  it 'should be able fetch activities electively' do
    fetch_activities('TheFernets', {:activities => :elective})
    reqs = $http_requests
    fetch_activities('TheFernets', {:activities => :elective})
    ($http_requests - reqs).should be_zero
  end

  it 'should be able fetch activities forcefully' do
    reqs = $http_requests
    fetch_activities('TheFernets', {:activities => :force})
    diff = $http_requests - reqs

    count = 1 # profile
    count += Rort::Models::Artist.find_or_fetch('TheFernets').reviews.size
    count += 1 # blog
    count += 1 # concert
    diff.should == count
  end
end
