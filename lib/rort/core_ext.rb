require 'rort/parsers'
include Rort::Parsers

class Time
  def verbose
    time_ago(self)
  end
end
