module Rort::External
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

    def song_review_path(review_id)
      "user/trackreviews.aspx?mmmid=#{review_id}&id=#{id}"
    end

    def songs_list
      (@doc/"#WebPart_gwpBandTracks .songmeta")
    end

    def song_name(song_id)
      if list = songs_list.at(".stats a[@href^='../../user/trackreviews" +
                              ".aspx?mmmid=#{song_id}']")#
        list.parent.parent.parent.at(".trackname").inner_text.strip
      else
        'En sang som er blitt slettet'
      end
    end

    def songs
      songs_list.collect do |song|

        id = song.at(".stats a[@href^='../../user/trackreviews']")[:href].
               scan(/mmmid=(\d+)/).flatten.first.to_i

        title = song.at(".trackname").inner_text.strip

        datetime = song.search(".stats").inner_text.strip.
            scan(/^(\d{2}\.\d{2}\.\d{4}) (\d{2}:\d{2}:\d{2})/).first

        time = parse_numeric_date(datetime[0]) + parse_time(datetime[1])

        activity(:song, Time.local(*time), song_review_path(id), title)
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

        activity(:review,
                 time,
                 song_review_path(id),
                 song_name(id),
                 { :rating => rating,
                   :comment => comment,
                   :reviewer => reviewer })
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
end