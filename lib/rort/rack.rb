$: << File.expand_path("../..", __FILE__)
require 'rort'
require 'rack'

options = { :Port => 8001,
            :Host => "0.0.0.0",
            :AccessLog => []
}

app = Rack::Builder.new {
  use Rack::CommonLogger, Rort.logger(:http)
  map '/' do
    run Rort::Http::Download.new
  end
  map '/api' do
    run Rort::Http::Api.new
  end
}.to_app

Rack::Handler::Mongrel.run app, options
