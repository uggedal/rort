module Rort::External
  class Artist < Fetchable

    def initialize(slug)
      @slug = slug
      @doc = fetch "Artist/#@slug"
    end

    def id
      (@doc%"#WebPart_gwpblog > a#rsslink")[:href][/subjectid=(\d+)/, 1]
    end

    def name
      (@doc%"head > title").text.strip[/^NRK Ur\303\270rt - (.+)/, 1]
    end

    def path
      "Artist/#@slug"
    end

    def full_url
      url(path)
    end

    def favorites
      thumb_elements("Favoritter p\303\245 Ur\303\270rt", 'Artist') do |e|
        (e%"img.Thumb")[:alt]
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
                              ".aspx?mmmid=#{song_id}']")
        list.parent.parent.parent.at(".trackname").text.strip
      else
        'En slettet sang'
      end
    end

    def songs
      songs_list.collect do |song|

        id = (song%".stats a[@href^='../../user/trackreviews']")[:href][
               /mmmid=(\d+)/, 1].to_i

        title = (song%".trackname").text.strip

        datetime = (song/".stats").text.strip.
            scan(/^(\d{2}\.\d{2}\.\d{4}) (\d{2}:\d{2}:\d{2})/).first

        time = parse_numeric_date(datetime[0]) + parse_time(datetime[1])

        activity(:song, Time.local(*time), song_review_path(id), title,
                 { :artist => name, :artist_url => url(path) })
      end
    end

    def reviews
      (@doc/"#WebPart_gwpReviewList tbody tr").collect do |review|

        id = (review%"td.said p small a[@onclick^='playBandTrack']"
               )[:onclick][/^playBandTrack\((\d+)\)/, 1].to_i

        rating = (review%"td.rating img")[:src][/tommel(\w{3})-voted.png$/, 1]
        rating = (rating == 'opp' ? 1 : 0)

        date = (review%"td.said p small").text.strip[/(^(.+)\n)/, 1].strip
        pattern = /(\d{1,2})\. (\w+) (\d{4})$/
        time = Time.local(*parse_textual_date(date, pattern))

        reviewer_slug = (review%"td.said h4 a[@href^='#{URL}Person']"
                          )[:href][/Person\/(\w+)/, 1]

        reviewer = Artist.as(reviewer_slug)

        comment = (review%"td.said p").text.strip[/(^(.+)\n)/, 1].strip

        activity(:review,
                 time,
                 song_review_path(id),
                 song_name(id),
                 { :rating => rating,
                   :comment => comment,
                   :reviewer => reviewer.name,
                   :reviewer_url => url(reviewer.path),
                   :artist => name,
                   :artist_url => url(path) })
      end
    end

    private

      def thumb_elements(header, path)
        element = (@doc%"h2[text()='#{header}']")

        return [] unless element

        element = element.next_sibling

        unless element[:class] || element[:class] == 'thumbgalery'
          element = element.next_sibling
        end

        (element/"a[@href^='../../#{path}']").collect do |e|
          { :slug => e[:href][/\/#{path}\/(\w+)$/, 1],
            :name => yield(e) }
        end
      end
  end
end
