module Rort::External
  class Blog < Fetchable

    def initialize(slug, author=nil)
      @slug = slug
      @author = author
      @doc = fetch "Blogg/#@slug"
    end

    def id
      @id ||= author.id
    end

    def author
      @author ||= Artist.as(@slug)
    end

    def post_path(post_id)
      "user/news2entry.aspx?articleid=#{post_id}&id=#{id}"
    end

    def posts
      div = (@doc/"#bandprofile-subpage")
      dates = (div/"div.posted-date").collect do |d|
        date = d.text.strip
        parse_textual_date(date, /\w+, (\d\d) (\w+), (\d\d\d\d)$/)
      end

      times = (div/"span.posted-by").collect do |s|
        parse_time(s.text[/klokka (\d\d:\d\d)/, 1])
      end

      ids = (div/"a[text()*='Kommentar']").collect do |a|
        a[:href][/articleid=(\d+)/, 1].to_i
      end

      titles = []
      summaries = []

      (div/"h4").each do |h4|
        titles << h4.text.strip
        summaries << h4.next_sibling.text.strip[0..100] + '...'
      end

      [dates, times, ids, titles, summaries].transpose.collect do |item|
        activity(:blog,
                 Time.local( *(item[0] + item[1]) ),
                 post_path(item[2]),
                 item[3],
                 {:summary => item[4],
                  :artist => author.name,
                  :artist_url => url(author.path)})
      end
    end
  end
end
