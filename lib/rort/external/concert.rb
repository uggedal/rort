module Rort::External
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

        activity(:concert,
                 Time.local(*time),
                 "Konserter/#@slug",
                 title,
                 { :location => location,
                   :comment => comment })
      end
    end
  end
end
