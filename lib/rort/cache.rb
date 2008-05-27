require 'memcache'

module Rort

  class Cache
    @enabled = false

    class << self
      attr_writer :expiry, :host
      
      def enable!
        @cache ||= MemCache.new(host, :namespace => 'rort')
        @enabled = true
      end

      def enabled?
        @enabled
      end

      def disabled?
        !enabled?
      end

      def [](key)
        return if disabled?
        case key
        when String
          @cache.get(key)
        when Array
          @cache.get_multi(key)
        end
      end
      
      def []=(key, value)
        return if disabled?
        @cache.set(key, value, expiry)
      end

      def del(key)
        return if disabled?
        @cache.delete(key)
      end
            
      def expiry
        @expiry ||= 60 * 10
      end
      
      def host
        @host ||= "localhost:11211"
      end

      def size
        @cache.stats[host]['bytes']
      end
    end
  end
end
