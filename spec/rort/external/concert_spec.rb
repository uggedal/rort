require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')

include Rort

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
      event[:datetime].should < Time.now
      event[:date].should_not be_empty
      event[:time].should_not be_empty
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
