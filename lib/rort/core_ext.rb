require 'rort/parsers'
include Rort::Parsers

class Time
  def verbose
    time_ago(self)
  end
end

require 'hpricot'
module Hpricot
  module Traverse
    alias_method :text, :inner_text
  end
end
