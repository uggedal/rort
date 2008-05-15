module Rort::External
  class Fetchable
    %w(hpricot open-uri).each { |lib| require lib }

    include Rort::Parsers

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
