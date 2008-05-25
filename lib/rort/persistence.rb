module Rort

  require 'sequel'

  class Persistence
    @@db = nil

    def self.db
      if $TESTING
        @@db ||= Sequel.sqlite
      else
        @@db ||= Sequel.sqlite File.expand_path('../../../rort.db', __FILE__)
      end
      @@db
    end
  end

  DB = Rort::Persistence.db
end
