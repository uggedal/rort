$: << File.expand_path("../..", __FILE__)
require 'rort'

def log(slug, opts)
  Rort.logger(:bg).info "#{slug} | #{opts} | Starting..."
  start = Time.now
  yield
  stop = Time.now
  Rort.logger(:bg).info "#{slug} | #{opts} | Finished in #{stop-start} sec"
end

def fetch_activities(slug, opts)
  if opts == :force || !Rort::Models::Artist.activities_cached?(slug)
    log(slug, opts) do
      Rort::Models::Artist.fetch(slug).activities
    end
  end
end

def fetch_favorites(slug, opts)
  if opts == :force || !Rort::Models::Artist.cached?(slug)
    log(slug, opts) do
      Rort::Models::Artist.fetch(slug)
    end
  end
end

loop do
  slug, opts = Rort::Queue.shift
  if slug
    if opts.key? :activities
      fetch_activities(slug, opts[:activities])
    elsif opts.key? :favorites
      fetch_favorites(slug, opts[:favorites])
    end
  end
  sleep 1
end
