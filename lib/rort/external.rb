module Rort::External
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

  class Artist < Fetchable

    def initialize(slug)
      @slug = slug
      @doc = fetch "Artist/#@slug"
    end

    def doc?
      if title = @doc.at("head > title")
        !(title.inner_text.strip =~
          /^NRK Ur\303\270rt - Ur\303\270rt fant ikke frem$/)
      else
        true
      end
    end

    def id
      @doc.at("#WebPart_gwpblog > a#rsslink")[:href].
        scan(/subjectid=(\d+)/).first.first
    end

    def name
      @doc.at("head > title").
        inner_text.strip.scan(/^NRK Ur\303\270rt - (.+)/).first.first
    end

    def thumb_elements(header, path)
      elements = @doc.at("h2[text()='#{header}']")

      return [] unless elements

      elements = elements.next_sibling.next_sibling

      elements.search("a[@href^='../../#{path}']").collect do |e|
        { :slug => e[:href].scan(/\/#{path}\/(\w+)$/).first.first,
          :name => yield(e) }
      end
    end

    def favorites
      thumb_elements("Favoritter p\303\245 Ur\303\270rt", 'Artist') do |e|
        e.at("img.Thumb")[:alt]
      end
    end

    def fans
      thumb_elements('Fans', 'Person') do |e|
        e[:title]
      end
    end
  end

  class Blog < Fetchable

    def initialize(id)
      @id = id
      @doc = fetch "user/news.aspx?id=#@id"
    end

    def doc?
      if title = @doc.at("head > title")
        !(title.inner_text.strip =~ /^NRK Ur\303\270rt - Feil$/)
      else
        true
      end
    end
  end
end
