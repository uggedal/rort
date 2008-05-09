module Rort
  VERSION = %w(0 2 0).join('.').freeze

  require 'rubygems'
  require 'rort/parsers'
  require 'rort/core_ext'
  require 'rort/external'
  require 'rort/cache'
  require 'rort/models'
  require 'rort/server'

  Cache.enable!
  Cache.expiry = 60*60*12 # 12 hr cache ttl

  def self.start
    @app = Rort::Server.new
  end
end
