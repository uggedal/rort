module Rort::External
  class Fetchable
    require 'hpricot'

    if $TESTING
      require 'openuri_memcached'
      OpenURI::Cache.enable!
      OpenURI::Cache.expiry = 60*60*12
    else 
      require 'open-uri'
    end

    include Rort::Parsers

    def doc?
      !( (@doc%"head > title").text.strip =~
          /^NRK Ur\303\270rt - Ur\303\270rt fant ikke frem$/ )
    end

    def existing?
      @doc && doc?
    end

    def self.as(*args)
      item = new(*args)
      if item && item.existing?
        yield item if block_given?
        item
      else
        nil
      end
    end

    protected
      URL = 'http://www11.nrk.no/urort/'

      def fetch(path)
        if res = request("#{URL}#{path}")
          Hpricot(res)
        else
          nil
        end
      end

      def url(path ='')
        "#{URL}#{path}"
      end

      def activity_date(time)
        time.verbose
      end

      def activity_time(time)
        time.strftime('%H:%M')
      end

      def activity(type, time, url, title, opts={})
        activity = {:type => type,
                    :date => activity_date(time),
                    :time => activity_time(time),
                    :datetime => time,
                    :url  => url(url),
                    :title => title}
        activity.merge(opts)
      end

    private
      @@openuri_loaded = false

      def request(uri)
        begin
          if $TESTING
            $http_requests += 1
          end
          open(uri)
        rescue OpenURI::HTTPError => e
          nil
        end
      end
  end
end
