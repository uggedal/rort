require 'halcyon'

module Rort
  VERSION = %w(0 0 1).join('.').freeze

  require 'rort/external'
  require 'rort/models'
  require 'rort/controllers'

  def self.start
    Halcyon::Runner.load_config
    Thin::Logging.silent = true if defined? Thin

    @app = Halcyon::Runner.new
  end
end
