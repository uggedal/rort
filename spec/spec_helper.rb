$: << File.expand_path("../../lib", __FILE__)

$TESTING = true

require 'rort'
require 'rack/mock'

$http_requests = 0
