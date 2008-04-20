module Rort::External
  class Blog < Fetchable

    def initialize(slug)
      @slug = slug
      @doc = fetch "Blogg/#@slug"
    end

    def id
      Artist.as(@slug).id
    end

    def post_path(post_id)
      "user/news2entry.aspx?articleid=#{post_id}&id=#{id}"
    end

    def posts
      div = (@doc/"#bandprofile-subpage")
      dates = div.search("div.posted-date").collect do |d|
        date = d.inner_text.strip
        pattern = /\w+, (\d\d) (\w+), (\d\d\d\d)$/
        parse_textual_date(date, pattern)
      end

      times = div.search("span.posted-by").collect do |s|
        parse_time(s.inner_text.scan(/klokka (\d\d:\d\d)/).flatten.first)
      end

      ids = div.search("a[text()$='Kommentarer']").collect do |a|
        a[:href].scan(/articleid=(\d+)/).flatten.first.to_i
      end

      titles = div.search("h4").collect {|h4| h4.inner_text.strip }

      [dates, times, ids, titles].transpose.collect do |item|
        activity(:blog,
                 Time.local( *(item[0] + item[1]) ),
                 post_path(item[2]),
                 item[3])
      end
    end
  end
end