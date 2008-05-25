module Rort
  require 'sequel'

  if $TESTING
    DB = Sequel.sqlite
  else
    DB = Sequel.sqlite File.expand_path('../../../rort.db', __FILE__)
  end
end
