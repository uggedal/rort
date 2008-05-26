require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Rort::Queue do

  before(:each) do
    Rort::Queue.clean
  end

  it 'should be able to push an item to the queue' do
    Rort::Queue.push(345).should == [345]
  end

  it 'should be able to shift an item from the queue' do
    Rort::Queue.push(345)
    Rort::Queue.shift.should == 345
  end

  it 'pushing an item to the queue should increase the size' do
    Rort::Queue.push(1).size.should == 1
    (2..99).each do |i|
      Rort::Queue.push(i)
    end
    Rort::Queue.push(100).size.should == 100
  end

  it 'shifting an item from the queue should decrease the size' do
    (1..99).each do |i|
      Rort::Queue.push(i)
    end
    Rort::Queue.push(100).size.should == 100

    (1..50).each do |i|
      Rort::Queue.shift.should == i
    end
    Rort::Queue.push(101).size.should == 51
  end

  it 'shifting when there are no items should return nil' do
    Rort::Queue.shift.should be_nil
  end

  it 'the queue should only store unique records' do
    Rort::Queue.push([:tada, {:some => 1}])
    Rort::Queue.push([:tada, {:some => 2}])
    Rort::Queue.push([:tada, {:some => 1}])

    Rort::Queue.shift.should == [:tada, {:some => 1}]
    Rort::Queue.shift.should == [:tada, {:some => 2}]
    Rort::Queue.shift.should be_nil

    Rort::Queue.push(345)
    Rort::Queue.push(345)
    Rort::Queue.push(345)

    Rort::Queue.shift.should == 345
    Rort::Queue.shift.should be_nil
  end
end
