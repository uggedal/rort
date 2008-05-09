require File.join(File.dirname(__FILE__), '..', 'spec_helper')

include Rort::Parsers

describe Rort::Parsers do

  it 'should be able to get a given date X days ago as array' do
    five_days = 60*60*24*5
    time = Time.now - five_days
    days_ago(5).should == [time.year, time.month, time.day]
  end

  it 'should be able to parse a textual date' do
    date = 'Mandag 12. FEBRUAR, 2008'
    pattern = /(\d{2})\. (\w+), (\d{4})/
    parsed = parse_textual_date(date, pattern)
    parsed.should == [2008, 2, 12]
  end

  it 'should be able to parse a verbose textual date' do
    today = 'i dag'
    yesterday = "i g\303\245r"
    pattern = /(\d{2})\. (\w+), (\d{4})/

    parsed_today = parse_textual_date(today, pattern)
    parsed_yesterday = parse_textual_date(yesterday, pattern)

    today = Time.now
    yesterday = today - 60*60*24
    parsed_today.should == [today.year, today.month, today.day]
    parsed_yesterday.should == [yesterday.year,
                                yesterday.month,
                                yesterday.day]
  end

  it 'should be able to parse a verbose textual date' do
    two = '2 dager siden'
    fourteen = '14 dager siden'
    pattern = /(\d{2})\. (\w+), (\d{4})/

    parsed_two = parse_textual_date(two, pattern)
    parsed_fourteen = parse_textual_date(fourteen, pattern)

    two = Time.now - 60*60*24*2
    fourteen = Time.now - 60*60*24*14
    parsed_two.should == [two.year, two.month, two.day]
    parsed_fourteen.should == [fourteen.year,
                                fourteen.month,
                                fourteen.day]
  end

  it 'should be able to parse a numeric date' do
    parsed = parse_numeric_date('24.12.2008')
    parsed.should == [2008, 12, 24]
  end

  it 'should be able to parse a numeric time' do
    parsed = parse_time('20:23')
    parsed_with_sec = parse_time('20:23:45')
    parsed.should == [20, 23]
    parsed_with_sec.should == [20, 23, 45]
  end

  it 'should be able to generate a verbose date' do
    today = Time.now
    today.verbose.should == 'I dag'
    yesterday = today - 60*60*24
    yesterday.verbose.should == 'I går'

    [2,3,4,5,6].each do |i|
      (today - 60*60*24*i).verbose.should == "#{i} dager siden"
    end
    [7,8,9,10,11,12,13].each do |i|
      (today - 60*60*24*i).verbose.should == "1 uke siden"
    end
    [14,15,16,17,18,19,20].each do |i|
      (today - 60*60*24*i).verbose.should == "2 uker siden"
    end
    [21,22,23,24,25,26,27].each do |i|
      (today - 60*60*24*i).verbose.should == "3 uker siden"
    end
    [28,29].each do |i|
      (today - 60*60*24*i).verbose.should == "4 uker siden"
    end

    (today - 60*60*24*30*1).verbose.should == "1 måned siden"
    [2,3,4,5,6,7,8,9,10,11].each do |i|
      (today - 60*60*24*30*i).verbose.should == "#{i} måneder siden"
    end

    [12,13,14,15,16,17,18,19,20,21,22,23].each do |i|
      (today - 60*60*24*30*i).verbose.should == "1 år siden"
    end
    [1,2,3,4,5,6,7,8,9].each do |i|
      (today - 60*60*24*30*12*i).verbose.should == "#{i} år siden"
    end

    (today + 60*60*24).verbose.should == 'I fremtiden'
  end

end
