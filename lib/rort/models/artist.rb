module Rort::Models

  class Artist < User

    def blog
      @blog ||= Rort::External::Blog.as(slug)
    end

    def songs
      @songs ||= external.songs
    end

    def concert
      @concert ||= Rort::External::Concert.as(slug)
    end

    def reviews
      @reviews ||= external.reviews
    end

    def activities
      unless activities = Artist.activities_cached?(slug)
        collection = [blog.posts, concert.events, songs, reviews]
        median = find_median_size(collection)
        activities = collection.collect do |elements|
          reverse_sort_by_datetime(elements)[0...median]
        end

        activities = reverse_sort_by_datetime(activities.flatten)
        Artist.activities_cache!(slug, activities)
      end
      activities
    end

    def self.find_or_fetch(slug)
      if cached = Rort::Cache[slug]
        cached
      else
        if fetched = Rort::External::Artist.as(slug)
          new = self.new(slug, fetched)
          Rort::Cache[slug] = new
          new
        else
          nil
        end
      end
    end

    def self.key(slug)
      "::activities::#{slug}::"
    end
    def self.activities_cached?(slug)
      Rort::Cache[key(slug)]
    end

    def self.activities_cache!(slug, activities)
      Rort::Cache[key(slug)] = activities
    end

    private

      def find_median_size(ary)
        sorted = ary.sort {|a, b| a.size <=> b.size}
        half = sorted.size / 2
        if half % 2 == 0
          sorted[half-1].size + sorted[half].size / 2
        else
          sorted[half].size
        end
      end
  end
end
