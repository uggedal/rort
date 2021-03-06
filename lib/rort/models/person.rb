module Rort::Models

  class Person < User

    def favorites
      @favorites ||= external_favorites
    end

    def favorite_list
      favorites.map do |fav|
        fav.favorite
      end
    end

    def activity_list
      act = favorite_activities
      fav = excluded_favorites(act)
      {:activities => act, :excludes => fav}
    end

    def favorite_activities
      activities = []
      cached = 0

      # If no favorites with cached activities, return one favorite and put
      # rest in queue.
      # If favorites with cached activities, return them and put the rest in
      # queue.
      favorites.each do |fav|
        if cached_activities = Artist.activities_cached?(fav.slug)
          cached += 1
          activities.concat(cached_activities)
        elsif cached == 0
          cached += 1
          activities.concat(fav.activities)
        else
          Rort::Queue.push([fav.slug, {:activities => :elective}])
        end
      end

      reverse_sort_by_datetime(activities)[0...Rort::MAX_ACTIVITIES]
    end

    def excluded_favorites(activities)
      excludes = []

      favorites.each do |fav|
        excluded = true

        activities.each do |act|
          excluded = false if fav.name == act[:artist]
        end

        if excluded
          excludes << {:artist => fav.name,
                       :artist_url => fav.external.full_url}
        end
      end
      excludes
    end

    def self.fetch(slug)
      if fetched = Rort::External::Artist.as(slug)
        self.new(slug, fetched)
      else
        nil
      end
    end

    private
      def external_favorites
        external.favorites.collect do |fav|
          Artist.find_or_create(fav)
        end
      end
  end
end
