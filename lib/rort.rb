module Rort
  VERSION = %w(0 2 0) * '.'

  require 'rubygems'

  require 'rort/parsers'
  require 'rort/core_ext'
  require 'rort/external'
  require 'rort/cache'
  require 'rort/persistence'
  require 'rort/models'
  require 'rort/http'
  require 'rort/queue'
  
  MAX_ACTIVITIES = 15

  Cache.enable!
  Cache.expiry = 60*60*12 # 12 hr cache ttl

  def self.root
    File.expand_path('../../', __FILE__)
  end

  require 'logger'

  def self.logger(type)
    @log ||= {}

    unless @log[type]
      path = File.expand_path("../../logs/#{type}.log", __FILE__)
      file = File.open(path, File::WRONLY | File::APPEND | File::CREAT)
      file.sync = true
      @log[type] = Logger.new(file)
    end
    @log[type]
  end
end
