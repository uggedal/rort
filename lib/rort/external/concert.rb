module Rort::External
  class Concert < Fetchable

    def initialize(slug)
      @slug = slug
      @doc = fetch "Konserter/#@slug"
    end

    def artist
      @artist ||= Artist.as(@slug)
    end

    def events
      events = []
      (@doc/"#bandprofile-subpage > ul > li").each do |event|

        location = (event%"span[@id$='_Label1']").text.strip
        datetime = (event%"span[@id$='_Label2']").text.strip.split
        title = (event%"span[@id$='_Label3']").text.strip
        comment_html = (event%"span[@id$='_Label4'] > p")
        comment = comment_html.text.strip if comment_html

        time = Time.local(*(parse_numeric_date(datetime[0]) +
                            parse_time(datetime[1])))

        events << activity(:concert,
                 time,
                 "Konserter/#@slug",
                 title,
                 { :location => location,
                   :comment => comment,
                   :artist => artist.name,
                   :artist_url => url(artist.path) }) if time < Time.now
      end
      events
    end
  end
end
