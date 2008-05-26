$: << File.expand_path("../..", __FILE__)
require 'rort'

module Rort::Background

  def log(slug, opts)

    if $TESTING
      yield
      return
    end

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
        Rort::Models::Artist.fetch(slug).activities(true)
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

  def check_queue
    slug, opts = Rort::Queue.shift
    if slug
      if opts.key? :activities
        fetch_activities(slug, opts)
      elsif opts.key? :favorites
        fetch_favorites(slug, opts)
      end
    end
  end
end

if __FILE__ == $0
  include Rort::Background

  loop do
    check_queue
    sleep 1
  end
end
