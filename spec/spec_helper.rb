$: << File.expand_path("../../lib", __FILE__)

require 'rort'
require 'rack/mock'

$TESTING = true
$HTTP_DEBUG = false
$http_requests = 0

Spec::Runner.configure do |config|

  config.after(:all) do
    if $HTTP_DEBUG
      puts "\nHTTP Requests: #$http_requests\n"
      $http_requests = 0
    end
  end
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
