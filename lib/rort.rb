module Rort
  VERSION = %w(0 2 0).join('.').freeze

  require 'rubygems'
  require 'rort/parsers'
  require 'rort/external'
  require 'rort/cache'
  require 'rort/models'
  require 'rort/server'

  Cache.enable!

  def self.start
    @app = Rort::Server.new
  end
end
