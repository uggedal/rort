$: << File.expand_path("../../../halcyon/lib", __FILE__)
$: << File.expand_path("../../lib", __FILE__)

require 'halcyon'
require 'roert'
require 'rack/mock'

Spec::Runner.configure do |config|
  config.before(:all) do
    @log = ''
    @logger = Logger.new(StringIO.new(@log))
    Halcyon.config = Halcyon::Runner.load_config
    Halcyon.config[:logger] = @logger
    Halcyon.config[:log_level] = 'debug'
    @app = Halcyon::Runner.new
  end
end

def url(name, params={})
  controller = Application.new(Rack::MockRequest.env_for("/"))
  controller.url(name, params)
end

def should_not_use_http_request
  before = Time.now.to_f
  yield
  after = Time.now.to_f

  (after - before).should < 0.05
end
