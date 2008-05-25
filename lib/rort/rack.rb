$: << File.expand_path("../..", __FILE__)
require 'rort'
require 'rack'

options = { :Port => 8001,
            :Host => "0.0.0.0",
            :AccessLog => []
}


Dir.chdir Rort.root

app = Rack::Builder.new do

  use Rack::CommonLogger, Rort.logger(:http)
  use Rack::Static, :urls => ["/doc"]

  map '/' do
    run Rort::Http::Download.new
  end

  map '/api' do
    run Rort::Http::Api.new
  end

end.to_app

Rack::Handler::Mongrel.run app, options
