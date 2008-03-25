require 'halcyon'

module Roert


  def self.start
    Halcyon::Runner.load_config Halcyon.root/'config'/'config.yml'
    Thin::Logging.silent = true if defined? Thin

    require 'roert/controller'
    require 'roert/persistence'

    @app = Halcyon::Runner.new
  end
end
