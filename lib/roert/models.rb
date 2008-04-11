require 'data_mapper'

DataMapper::Database.setup({
  :adapter  => 'sqlite3',
  :database => 'roert.db'
})

module Roert::Models

  class Artist < DataMapper::Base
    property :slug, :string
    property :name, :string

    has_and_belongs_to_many :favorites,
      :join_table => 'favorites',
      :left_foreign_key => 'parent_id',
      :right_foreign_key => 'child_id',
      :class => 'Artist'

    def self.find_or_fetch(slug)
      if existing = Artist.first(:slug => slug)
        existing
      else
        fetched = Roert::Fetch::Artist.as(slug)
        if fetched.existing?
          Artist.create(:slug => slug)
        else
          nil
        end
      end
    end
  end
end
