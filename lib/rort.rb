require 'halcyon'

module Rort
  VERSION = %w(0 0 1).join('.').freeze

  require 'rort/controllers'
  require 'rort/models'
  require 'rort/external'


  def self.start
    Halcyon::Runner.load_config
    Thin::Logging.silent = true if defined? Thin

    @app = Halcyon::Runner.new
  end
end
