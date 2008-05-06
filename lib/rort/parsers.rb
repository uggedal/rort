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
                when /(\d{1,2}) dager siden$/
                  days_ago $1.to_i
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

  DAY = 60*60*24
  WEEK = DAY*7
  MONTH = DAY*30
  YEAR = MONTH*12

  def time_ago(time)
    diff = Time.now - time

    return 'I fremtiden' if diff < 0

    case diff
    when 0..DAY
      'I dag'
    when DAY..(2*DAY)
      'I går'
    when (2*DAY)..WEEK
      "#{(diff / DAY).to_i} dager siden"
    when WEEK..MONTH
      weeks = (diff / WEEK).to_i
      text = (weeks == 1 ? 'uke' : 'uker')
      "#{weeks} #{text} siden"
    when MONTH..YEAR
      months = (diff / MONTH).to_i
      text = (months == 1 ? 'måned' : 'måneder')
      "#{months} #{text} siden"
    else
      "#{(diff / YEAR).to_i} år siden"
    end
  end
end
