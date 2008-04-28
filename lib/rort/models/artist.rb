module Rort::Models

  class Artist

    def initialize(slug, external=nil)
      @slug = slug
      @external = external
    end

    attr_reader :slug
    attr_writer :name

    def external
      @external ||= Rort::External::Artist.as(slug)
    end

    def id
      @name ||= external.id
    end

    def name
      @name ||= external.name
    end

    def favorites
      @favorites ||= external_favorites
    end

    def fans
      @fans ||= external_fans
    end

    def friends
      friends = []
      favorites.each do |fav|
        friends = friends | fav.fans
      end
      friends
    end

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

    def reverse_sort_by_datetime(items)
      items.sort { |a,b| b[:datetime] <=> a[:datetime] }
    end

    def find_median_size(ary)
      sorted = ary.sort {|a, b| a.size <=> b.size}
      half = sorted.size / 2
      if half % 2 == 0
        sorted[half-1].size + sorted[half].size / 2
      else
        sorted[half].size
      end
    end

    def activities
      unless activities = Rort::Cache[slug + ':activities']
        collection = [blog.posts, concert.events, songs, reviews]
        median = find_median_size(collection)
        activities = collection.collect do |elements|
          elements[0...median]
        end

        activities = reverse_sort_by_datetime(activities.flatten)
        Rort::Cache[slug + ':activities'] = activities
      end
      activities
    end

    def favorite_activities
      activities = []
      favorites.each do |fav|
        activities.concat(fav.activities)
      end

      reverse_sort_by_datetime(activities)
    end

    def to_json(*arg)
      { 'slug' => slug,
        'name' => name}.to_json(*arg)
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

    private

      def self.find_or_create(artist)
        if cached = Rort::Cache[artist[:slug]]
          cached
        else
          new = self.new(artist[:slug])
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

      def external_fans
        external.fans.collect do |fan|
          self.class.find_or_create(fan)
        end
      end
  end
end
