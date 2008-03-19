require 'rubygems'
require 'roert/server'

module Roert

  def self.conf
    YAML.load_file(File.join(File.expand_path("../../config", __FILE__),
                             'server.yml')).symbolize_keys!
  end

  def self.serve
    Rack::Handler::Mongrel.run(Roert::Server.new(conf),
                               :Port => conf[:port])
  end
end
