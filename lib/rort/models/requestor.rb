module Rort::Models

  DB = Rort::Persistence.db

  class Requestor < Sequel::Model

    set_schema do
      primary_key :id
      text        :slug, :unique => true, :null => false
      integer     :requests, :default => 0
      timestamp   :created_at
    end

    before_create do
      self.created_at = Time.now
    end

    def self.increment_or_create(slug)
      requestor = Requestor.find_or_create :slug => slug
      requestor.requests = requestor.requests + 1
      requestor.save
      requestor
    end
  end

  Requestor.create_table unless Requestor.table_exists?
end
