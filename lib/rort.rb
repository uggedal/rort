module Rort
  VERSION = %w(0 2 0).join('.').freeze

  require 'rubygems'
  require 'rort/parsers'
  require 'rort/core_ext'
  require 'rort/external'
  require 'rort/cache'
  require 'rort/models'
  require 'rort/http'
  require 'rort/queue'
  
  TIMEOUT = 10
  MAX_ACTIVITIES = 15

  Cache.enable!
  Cache.expiry = 60*60*12 # 12 hr cache ttl

  def self.start
    @app = Rort::Http.new
  end

  def self.root
    File.expand_path('../../', __FILE__)
  end
end
