$: << File.expand_path("../../halcyon/lib", __FILE__)
$: << File.expand_path("../lib", __FILE__)

require 'roert'

Halcyon::Runner.load_config Halcyon.root/'config'/'config.yml'

run Halcyon::Runner.new
