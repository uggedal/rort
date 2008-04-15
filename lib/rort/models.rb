require 'rort/external'


module Rort::Models

  class Cache
    @enabled = false

    class << self
      attr_writer :expiry, :host
      
      def enable!
        @cache ||= MemCache.new(host, :namespace => 'rort')
        @enabled = true
      end

      def enabled?
        @enabled
      end

      def [](key)
        case key
        when String
          @cache.get(key)
        when Array
          @cache.get_multi(key)
        end
      end
      
      def []=(key, value)
        @cache.set(key, value, expiry)
      end

      def del(key)
        @cache.delete(key)
      end
            
      def expiry
        @expiry ||= 60 * 10
      end
      
      def host
        @host ||= "localhost:11211"
      end
    end
  end

  Cache.enable!

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

    def to_json(*arg)
      { 'slug' => slug,
        'name' => name}.to_json(*arg)
    end

    def self.find_or_fetch(slug)
      if cached = Cache[slug]
        cached
      else
        if fetched = Rort::External::Artist.as(slug)
          new = self.new(slug, fetched)
          Cache[slug] = new
          new
        else
          nil
        end
      end
    end

    def self.find_or_create(artist)
      if cached = Cache[artist[:slug]]
        cached
      else
        new = self.new(artist[:slug])
        new.name = artist[:name]
        Cache[new.slug] = new
        new
      end
    end

    private

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
