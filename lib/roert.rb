require 'halcyon'

module Roert

  def self.serve
    puts "(Starting in #{Halcyon.root})"

    Halcyon::Runner.load_config Halcyon.root/'config'/'config.yml'
    Thin::Logging.silent = true if defined? Thin

    require 'roert/controller'
    require 'roert/persistence'

    @app = Halcyon::Runner.new
  end
end
