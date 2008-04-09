$: << File.expand_path("../../../halcyon/lib", __FILE__)
$: << File.expand_path("../../lib", __FILE__)

require 'halcyon'
require 'roert'
require 'rack/mock'

$config = {:allow_from => :all,
           :logger => nil,
           :log_level => 'debug'}

Spec::Runner.configure do |config|
  config.before(:all) do
    @log = ''
    @logger = Logger.new(StringIO.new(@log))
    @config = $config.dup
    @config[:logger] = @logger
    Halcyon.config = @config
    @app = Halcyon::Runner.new
  end
end

