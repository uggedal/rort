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

      def [](key)
        case key
        when String
          @cache.get(key)
        when Array
          @cache.get_multi(key)
        end
      end
      
      def []=(key, value)
        @cache.set(key, value, expiry)
      end

      def del(key)
        @cache.delete(key)
      end
            
      def expiry
        @expiry ||= 60 * 10
      end
      
      def host
        @host ||= "localhost:11211"
      end
    end
  end
end