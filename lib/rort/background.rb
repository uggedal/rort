$: << File.expand_path("../..", __FILE__)
require 'rort'

def log(slug)
  Rort.logger(:bg).info "Fetching | #{slug} | Starting..."
  start = Time.now
  yield
  stop = Time.now
  Rort.logger(:bg).info "Fetching | #{slug} | Finished in #{stop-start} sec"
end

loop do
  if slug = Rort::Queue.shift
    unless Rort::Cache[slug + ':activities']
      log(slug) do
        Rort::Models::Artist.find_or_fetch(slug).activities
      end
    end
  end
  sleep 1
end
