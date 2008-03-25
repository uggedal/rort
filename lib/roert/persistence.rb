require 'data_mapper'

DataMapper::Database.setup({
  :adapter  => 'sqlite3',
  :database => 'roert.db'
})

module Roert::Persistence

  class Sentence < DataMapper::Base
    property :interjection, :string
    property :noun, :string
    property :suffix, :string
  end
end
