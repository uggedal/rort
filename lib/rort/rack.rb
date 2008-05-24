$: << File.expand_path("../..", __FILE__)
require 'rort'
require 'rack'

options = { :Port => 8001,
            :Host => "0.0.0.0",
            :AccessLog => []
}

app = Rack::Builder.new {
  use Rack::CommonLogger, Rort.logger(:http)
  run Rort.start
}.to_app

Rack::Handler::Mongrel.run app, options
