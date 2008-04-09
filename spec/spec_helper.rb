$: << File.expand_path("../../../halcyon/lib", __FILE__)
$: << File.expand_path("../../lib", __FILE__)

require 'halcyon'
require 'roert'
require 'rack/mock'

Spec::Runner.configure do |config|
  config.before(:all) do
    @log = ''
    @logger = Logger.new(StringIO.new(@log))
    Halcyon::Runner.load_config Halcyon.root/'config'/'config.yml'
    Halcyon.config[:logger] = @logger
    Halcyon.config[:log_level] = 'debug'
    @app = Halcyon::Runner.new
  end
end

