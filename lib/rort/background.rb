$: << File.expand_path("../..", __FILE__)
require 'rort'

def log(msg)
  start = Time.now
  puts "#{start} | #{msg} | Starting..."
  yield
  stop = Time.now
  puts "#{stop} | #{msg} | Finished in #{stop-start} sec"
end

loop do
  if slug = Rort::Queue.shift
    log(slug) do
      Rort::Models::Person.fetch(slug).favorite_activities
    end
  end
  sleep 1
end
