module Rort::Models

  class Artist < User

    def blog
      @blog ||= Rort::External::Blog.as(slug, external)
    end

    def songs
      @songs ||= external.songs
    end

    def concert
      @concert ||= Rort::External::Concert.as(slug, external)
    end

    def reviews
      @reviews ||= external.reviews
    end

    def activities(force = false)
      if force || !activities = Artist.activities_cached?(slug)
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

    # Fetch an artist and forcefully write it to cache,
    # overwriting a potentially cached artist
    def self.fetch(slug)
      if fetched = Rort::External::Artist.as(slug)
        new = self.new(slug, fetched)
        self.cache!(slug, new)
        new
      else
        nil
      end
    end

    # Return an artist from cache if it's cached or
    # fetch it on a cache miss.
    def self.find_or_fetch(slug)
      if cached = self.cached?(slug)
        cached
      else
        self.fetch(slug)
      end
    end

    # Return an artist form cache if it's cached or create a
    # new artist with name and cache it on a cache miss.
    def self.find_or_create(artist)
      if cached = self.cached?(artist[:slug])
        cached
      else
        new = Artist.new(artist[:slug])
        new.name = artist[:name]
        self.cache!(artist[:slug], new)
        new
      end
    end

    def self.activities_key(slug)
      "::activities::#{slug}::"
    end

    def self.activities_cached?(slug)
      Rort::Cache[activities_key(slug)]
    end

    def self.activities_cache!(slug, activities)
      Rort::Cache[activities_key(slug)] = activities
    end

    def self.activities_clean_cache!(slug)
      Rort::Cache.del(activities_key(slug))
    end

    def self.key(slug)
      "::artist::#{slug}::"
    end

    def self.cached?(slug)
      Rort::Cache[key(slug)]
    end

    def self.cache!(slug, artist)
      Rort::Cache[key(slug)] = artist
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
