module Rort

  class Queue

    class << self

      QKEY = '::rort::queue::'

      def push(element)
        ary = Rort::Cache[QKEY]
        if ary
          ary.each { |a| return ary if a == element }
          ary.push(element)
        else
          ary = [element]
        end
        Rort::Cache[QKEY] = ary
      end

      def shift
        value = nil
        ary = Rort::Cache[QKEY]
        if ary
          value = ary.shift
          clean
          Rort::Cache[QKEY] = ary
        end
        value
      end

      def clean
        Rort::Cache.del(QKEY)
      end
    end
  end
end
