module Rort::External
  class Fetchable
    %w(hpricot openuri_memcached).each { |lib| require lib }

    include Rort::Parsers

    OpenURI::Cache.enable!
    OpenURI::Cache.expiry = 60 * 60

    # Increase the buffer because of unpredictable ASP.NET viewstates.
    # Should possibly patch Hpricot to handle arbitrarily sized elements.
    Hpricot.buffer_size = 262144

    def doc?
      !(@doc.at("head > title").inner_text.strip =~
          /^NRK Ur\303\270rt - Ur\303\270rt fant ikke frem$/)
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

      def activity(type, time, url, title, opts={})
        activity = {:type => type,
                    :time => time,
                    :url  => url(url),
                    :title => title}
        activity.merge(opts)
      end

    private
      def request(uri)
        begin
          if $HTTP_DEBUG
            $http_requests += 1
            puts "Fetch: #{uri}"
          end
          open(uri)
        rescue OpenURI::HTTPError => e
          nil
        end
      end
  end
end
