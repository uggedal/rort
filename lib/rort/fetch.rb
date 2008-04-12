module Rort::Fetch
  %w(hpricot openuri_memcached).each { |lib| require lib }

  OpenURI::Cache.enable!
  OpenURI::Cache.expiry = 60 * 60

  # Increase the buffer because of unpredictable ASP.NET viewstates.
  # Should possibly patch Hpricot to handle arbitrarily sized elements.
  Hpricot.buffer_size = 262144

  class Fetchable

    def doc?
      true
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

    private
      def request(uri)
        begin
          open(uri)
        rescue OpenURI::HTTPError => e
          nil
        end
      end
  end

  class Artist < Fetchable

    def initialize(slug)
      @slug = slug
      @doc = fetch "Artist/#@slug"
    end

    def doc?
      if h1 = @doc.at("h1")
        h1.inner_text =~ /^Fant ikke personen \/ artisten$/
      else
        true
      end
    end

    def name
      @doc.at("h2#ctl00_ContentCPH_Menu1_title").
        inner_text.scan(/^([\w -]+)/).first.first
    end

    def favorites

      favs_el = @doc.at("h2[text()*='Favoritter p']").
        next_sibling.next_sibling

      favs_el.search("a[@href^='../../Artist']").collect do |e|
        { :slug => e[:href].scan(/\/Artist\/(\w+)$/).first.first,
          :name => e.at("img.Thumb")[:title] }
      end
    end
  end
end
