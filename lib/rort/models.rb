require 'data_mapper'

DataMapper::Database.setup({
  :adapter  => 'sqlite3',
  :database => 'rort.db'
})

module Rort::Models

  class Artist < DataMapper::Base
    property :slug, :string, :key => true
    property :name, :string, :lazy => true

    has_and_belongs_to_many :favorites,
      :join_table => 'favorites',
      :left_foreign_key => 'parent_id',
      :right_foreign_key => 'child_id',
      :class => 'Artist'

    has_and_belongs_to_many :fans,
      :join_table => 'fans',
      :left_foreign_key => 'parent_id',
      :right_foreign_key => 'child_id',
      :class => 'Artist'

    attr_writer :external

    def external
      @external ||= Rort::External::Artist.as(slug)
    end

    def name
      @name ? @name : external.name
    end

    alias :associated_favorites :favorites

    def favorites
      external_favorites unless @favorites && @favorites.size > 0
      associated_favorites
    end

    alias :associated_fans :fans

    def fans
      external_fans unless @fans && @fans.size > 0
      associated_fans
    end

    def self.find_or_fetch(slug)
      if existing = Artist.first(slug)
        existing
      else
        if fetched = Rort::External::Artist.as(slug)
          new = Artist.new(:slug => slug)
          new.external = fetched
          new.save
          new
        else
          nil
        end
      end
    end
    
    private

      def external_favorites
        if external
          associated_favorites << external.favorites.collect do |fav|
            self.class.find_or_create({:slug => fav[:slug]}, fav)
          end
        end
      end

      def external_fans
        if external
          associated_fans << external.fans.collect do |fan|
            self.class.find_or_create({:slug => fan[:slug]}, fan)
          end
        end
      end
  end
end
