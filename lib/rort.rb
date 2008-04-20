require 'halcyon'

module Rort
  VERSION = %w(0 2 0).join('.').freeze

  require 'rort/parsers'
  require 'rort/external'
  require 'rort/cache'
  require 'rort/models'
  require 'rort/controllers'

  Cache.enable!

  def self.start
    Halcyon::Runner.load_config
    Thin::Logging.silent = true if defined? Thin

    @app = Halcyon::Runner.new
  end
end
