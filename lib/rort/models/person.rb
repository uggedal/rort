module Rort::Models

  class Person < User

    def favorites
      @favorites ||= external_favorites
    end

    def favorite_activities
      start = Time.now
      activities = []

      for fav in favorites
        if (Time.now-start) < Rort::TIMEOUT
          activities.concat(fav.activities)
        else
          Rort::Queue.push(slug)
        end
      end

      reverse_sort_by_datetime(activities)[0...Rort::MAX_ACTIVITIES]
    end

    def self.fetch(slug)
      if fetched = Rort::External::Artist.as(slug)
        self.new(slug, fetched)
      else
        nil
      end
    end

    private
      def self.find_or_create(artist)
        if cached = Rort::Cache[artist[:slug]]
          cached
        else
          new = Artist.new(artist[:slug])
          new.name = artist[:name]
          Rort::Cache[new.slug] = new
          new
        end
      end

      def external_favorites
        external.favorites.collect do |fav|
          self.class.find_or_create(fav)
        end
      end
  end
end
