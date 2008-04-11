require 'data_mapper'

DataMapper::Database.setup({
  :adapter  => 'sqlite3',
  :database => 'roert.db'
})

module Roert::Models

  class Artist < DataMapper::Base
    property :slug, :string, :key => true
    property :name, :string

    has_and_belongs_to_many :favorites,
      :join_table => 'favorites',
      :left_foreign_key => 'parent_id',
      :right_foreign_key => 'child_id',
      :class => 'Artist'

    attr_writer :external

    def external
      @external ||= Roert::Fetch::Artist.as(slug)
    end

    def name
      @name ||= external.name if external
    end

    alias :associated_favorites :favorites

    def favorites
      external_favorites unless @artists && @artists.size > 0
      associated_favorites
    end

    def external_favorites
      if external
        associated_favorites << external.favorites.collect do |fav|
          self.class.find_or_create({:slug => fav[:slug]}, fav)
        end
      end
    end

    def self.find_or_fetch(slug)
      if existing = Artist.first(slug)
        existing
      else
        if fetched = Roert::Fetch::Artist.as(slug)
          new = Artist.new(:slug => slug)
          new.external = fetched
          new.save
          new
        else
          nil
        end
      end
    end
  end
end
