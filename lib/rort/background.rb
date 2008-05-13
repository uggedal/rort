$: << File.expand_path("../..", __FILE__)
require 'rort'

loop do
  if slug = Rort::Queue.shift
    Rort::Models::Person.fetch(slug).favorite_activities
  end
  sleep 1
end
