module Rort::External
  %w(hpricot openuri_memcached).each { |lib| require lib }

  OpenURI::Cache.enable!
  OpenURI::Cache.expiry = 60 * 60

  # Increase the buffer because of unpredictable ASP.NET viewstates.
  # Should possibly patch Hpricot to handle arbitrarily sized elements.
  Hpricot.buffer_size = 262144

  class Fetchable

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

    def parse_textual_date(date, pattern)
      matched = date.scan(pattern).flatten.reverse

      if matched.empty?
        matched = case date
                  when /^Skrevet i dag$/
                    Time.now.strftime('%Y %m %d').split
                  end
      else
        matched[1] = case matched[1].downcase
                     when 'januar'
                       1
                     when 'februar'
                       2
                     when 'mars'
                       3
                     when 'april'
                       4
                     when 'mai'
                       5
                     when 'juni'
                       6
                     when 'juli'
                       7
                     when 'august'
                       8
                     when 'september'
                       9
                     when 'oktober'
                       10
                     when 'november'
                       11
                     when 'desember'
                       12
                     end
      end
      matched.collect {|part| part.to_i }
    end

    def parse_numeric_date(str)
      str.split('.').reverse.collect {|part| part.to_i }
    end

    def parse_time(str)
      str.split(':').collect {|part| part.to_i }
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

    def id
      @doc.at("#WebPart_gwpblog > a#rsslink")[:href].
        scan(/subjectid=(\d+)/).first.first
    end

    def name
      @doc.at("head > title").
        inner_text.strip.scan(/^NRK Ur\303\270rt - (.+)/).first.first
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

    def songs
      songs = (@doc/"#WebPart_gwpBandTracks .songmeta")

      ids = songs.search(".stats a[@href^='../../user/trackreviews']").collect do |a|
        a[:href].scan(/mmmid=(\d+)/).flatten.first.to_i
      end

      names = songs.search(".trackname").collect do |name|
        name.inner_text.strip
      end

      datetimes = songs.search(".stats").collect do |stat|
        datetime = stat.inner_text.strip.
          scan(/^(\d{2}\.\d{2}\.\d{4}) (\d{2}:\d{2}:\d{2})/).first

        parse_numeric_date(datetime[0]) + parse_time(datetime[1])
      end

      [ids, names, datetimes].transpose.collect do |item|
        {:id => item[0], :name => item[1], :time => Time.local(*item[2])}
      end
    end

    def reviews
      (@doc/"#WebPart_gwpReviewList .singlereview").collect do |review|

        id = review.at("a[@onclick^='playBandTrack']")[:onclick].
               scan(/^playBandTrack\((\d+)\)/).flatten.first.to_i

        rating = review.at("img.trackreviewStars")[:src].
                   scan(/_(\d)\.png$/).flatten.first.to_i

        date = review.at(".Writtenat").inner_text.strip
        pattern = /(\d{1,2})\. (\w+) (\d{4})$/
        time = Time.local(*parse_textual_date(date, pattern))

        reviewer = review.
                     at(".trackReviewHeader a[@href^='#{URL}Person']")[:href].
                       scan(/Person\/(\w+)/).flatten.first

        comment = review.at(".trackReviewFull").inner_text.strip

        {:id => id,
         :time => time,
         :reviewer => reviewer,
         :rating => rating,
         :comment => comment}
      end
    end

    private

      def thumb_elements(header, path)
        elements = @doc.at("h2[text()='#{header}']")

        return [] unless elements

        elements = elements.next_sibling.next_sibling

        elements.search("a[@href^='../../#{path}']").collect do |e|
          { :slug => e[:href].scan(/\/#{path}\/(\w+)$/).first.first,
            :name => yield(e) }
        end
      end
  end

  class Blog < Fetchable

    def initialize(slug)
      @slug = slug
      @doc = fetch "Blogg/#@slug"
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

      [ids, dates, times].transpose.collect do |item|
        {:id => item[0], :time => Time.local(*(item[1] + item[2]))}
      end
    end
  end

  class Concert < Fetchable

    def initialize(slug)
      @slug = slug
      @doc = fetch "Konserter/#@slug"
    end

    def events
      (@doc/"#bandprofile-subpage > ul > li").collect do |event|

        location = event.at("span[@id$='_Label1']").inner_text.strip
        datetime = event.at("span[@id$='_Label2']").inner_text.strip.split
        title = event.at("span[@id$='_Label3']").inner_text.strip
        comment = event.at("span[@id$='_Label4'] > p").inner_text.strip

        time = parse_numeric_date(datetime[0]) + parse_time(datetime[1])

        {:location => location,
         :time => Time.local(*time),
         :title => title,
         :comment => comment}
      end
    end
  end
end
