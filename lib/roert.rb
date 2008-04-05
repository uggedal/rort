require 'halcyon'

module Roert
  require 'roert/server'
  require 'roert/persistence'


  def self.start
    Halcyon::Runner.load_config Halcyon.root/'config'/'config.yml'
    Thin::Logging.silent = true if defined? Thin

    @app = Halcyon::Runner.new
  end
end
