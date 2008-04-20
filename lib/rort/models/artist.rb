require 'rort/external'

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

    def activities
      activities = blog.posts
      activities.concat(songs)
      activities.concat(concert.events)
      activities.concat(reviews)

      activities.sort { |a,b| b[:datetime] <=> a[:datetime] }
    end

    def favorite_activities
      activities = favorites.collect do |fav|
        fav.activities
      end

      activities.flatten.sort do |a,b|
        b[:datetime] <=> a[:datetime]
      end
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
