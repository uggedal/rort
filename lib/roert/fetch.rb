module Roert::Fetch
  %w(hpricot open-uri).each { |lib| require lib }

  class Fetchable

    def initialize(*args)
      yield if block_given?
    end

    class << self
      alias :as :new
    end

    protected
      URL = 'http://www11.nrk.no/urort/'

      def fetch(path)
        Hpricot(open("#{URL}#{path}"))
      end
  end

  class Artist < Fetchable

    def initialize(slug)
      @doc = fetch "Artist/#{slug}"
      @slug = slug

      
    end

    def name
      @doc.at("h2#ctl00_ContentCPH_Menu1_title").inner_html
    end

    def favorites
      favorites = @doc.at("h2[text()*='Favoritter p']").
        next_sibling.next_sibling.
        search("a[@href^='../../Artist']").collect do |e|
          e[:href].scan(/\/Artist\/(\w+)$/).first
      end
      favorites
    end
  end
end
