module Rort::Parsers

  def days_ago(days)
    ago = Time.now - days*60*60*24
    [ago.year, ago.month, ago.day]
  end

  def parse_textual_date(date, pattern)
    matched = date.scan(pattern).flatten.reverse

    if matched.empty?
      matched = case date
                when /i dag$/
                  days_ago 0
                when /i g\303\245r$/
                  days_ago 1
                end
    else
      matched[1] = case matched[1].downcase
                   when 'januar'
                     1
                   when 'februar'
                     2
                   when 'mars'
                     3
                   when 'april'
                     4
                   when 'mai'
                     5
                   when 'juni'
                     6
                   when 'juli'
                     7
                   when 'august'
                     8
                   when 'september'
                     9
                   when 'oktober'
                     10
                   when 'november'
                     11
                   when 'desember'
                     12
                   end
    end
    matched.collect {|part| part.to_i }
  end

  def parse_numeric_date(str)
    str.split('.').reverse.collect {|part| part.to_i }
  end

  def parse_time(str)
    str.split(':').collect {|part| part.to_i }
  end
end
