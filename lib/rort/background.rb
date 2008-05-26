$: << File.expand_path("../..", __FILE__)
require 'rort'

def log(slug, opts)
  Rort.logger(:bg).info "#{slug} #{opts.inspect} Starting..."
  start = Time.now
  yield
  stop = Time.now
  Rort.logger(:bg).info "#{slug} #{opts.inspect} Finished: #{stop-start} sec"
end

def fetch_activities(slug, opts)
  if opts[:activities] == :force || !Rort::Models::Artist.
                                      activities_cached?(slug)
    log(slug, opts) do
      Rort::Models::Artist.fetch(slug).activities
    end
  end
end

def fetch_favorites(slug, opts)
  if opts[:favorites] == :force || !Rort::Models::Artist.cached?(slug)
    log(slug, opts) do
      Rort::Models::Artist.fetch(slug)
    end
  end
end

loop do
  slug, opts = Rort::Queue.shift
  if slug
    if opts.key? :activities
      fetch_activities(slug, opts)
    elsif opts.key? :favorites
      fetch_favorites(slug, opts)
    end
  end
  sleep 1
end
