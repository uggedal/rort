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
end
