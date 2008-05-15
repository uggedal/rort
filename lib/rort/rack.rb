$: << File.expand_path("../..", __FILE__)
require 'rort'
require 'rack'

options = { :Port => 8001,
            :Host => "0.0.0.0",
            :AccessLog => []
}

app = Rack::Builder.new {
  use Rack::CommonLogger, STDERR
  run Rort.start
}.to_app

Rack::Handler::Mongrel.run app, options
