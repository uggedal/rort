module Roert::Fetch
  %w(hpricot open-uri).each { |lib| require lib }

  def artist(slug)
    a = {}
    doc = get "Artist/#{slug}"
    a[:name] = doc.at("h2#ctl00_ContentCPH_Menu1_title").inner_html
    a[:favorites] = doc.at("h2[text()*='Favoritter p']").
      next_sibling.next_sibling.
      search("a[@href^='../../Artist']").collect do |e|
        e[:href].scan(/\/Artist\/(\w+)$/).first
    end

    
    #a[:favorites] = (doc/".thumbgallery > a[@id^='ctl00_ContentCPH_webPartManager_gwpMyFavorites_MyFavorites_MyFavsRepeater'")
    #a[:favorites].each do |f|
    #  f.at("a[href]^=''")
    #end
    a
  end

  private
    URL = 'http://www11.nrk.no/urort/'

    def get(path)
      Hpricot(open("#{URL}#{path}"))
    end
end
