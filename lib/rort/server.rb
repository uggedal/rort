require 'rack/request'
require 'rort/models'
require 'json'

module Rort
  class Server

    DEFAULT_HEADERS = { 'Content-Type' => 'application/json' }

    def call(env)
      req = Rack::Request.new(env)

      def match?(req, key)
        & req.params.key?(key)
      end

      if req.params.empty?
      if match?(req, 'favorites') && body = favorites_of(req['favorites'])
        [200, DEFAULT_HEADERS, body]
      else
        [404, DEFAULT_HEADERS, '']
      end
    end

    def favorites_of(slug)
      artist = Rort::Models::Person.fetch(slug)
      artist ? artist.favorite_activities.to_json : nil
    end
  end
end
