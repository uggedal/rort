$: << File.expand_path("../../../halcyon/lib", __FILE__)
$: << File.expand_path("../../lib", __FILE__)

require 'halcyon'
require 'rort'
require 'rack/mock'

$HTTP_DEBUG = true
$http_requests = 0

Spec::Runner.configure do |config|
  config.before(:all) do
    @log = ''
    @logger = Logger.new(StringIO.new(@log))
    Halcyon.config = Halcyon::Runner.load_config
    Halcyon.config[:logger] = @logger
    Halcyon.config[:log_level] = 'debug'
    @app = Halcyon::Runner.new
  end

  config.after(:all) do
    if $HTTP_DEBUG
      puts "\nHTTP Requests: #$http_requests\n"
      $http_requests = 0
    end
  end
end

def url(name, params={})
  controller = Application.new(Rack::MockRequest.env_for("/"))
  controller.url(name, params)
end

module OpenURI
  class HTTPNotAllowedError < StandardError
    def initialize(message)
      super(message)
    end
  end
end

def should_not_use_http_request

  Kernel.module_eval do
    alias original_open_uri_open open

    def open(name, *rest, &block)
      raise OpenURI::HTTPNotAllowedError, 'OpenURI::open should not be called'
    end
  end

  begin
    yield
  rescue OpenURI::HTTPNotAllowedError => e
    pending e
  end
  
  Kernel.module_eval do
    alias open original_open_uri_open
  end
end
