require 'rack/request'
require 'rort/models'
require 'json'

module Rort
  class Server

    DEFAULT_HEADERS = { 'Content-Type' => 'application/json' }

    def call(env)
      req = Rack::Request.new(env)

      if req.params.any? && req.params.key?('favorites')
        body = activities_for_favorites_of(req['favorites'])
        [200, DEFAULT_HEADERS, [body]]
      else
        [404, DEFAULT_HEADERS, ['']]
      end
    end

    def activities_for_favorites_of(slug)
      return nil unless slug
      Rort::Models::Artist.find_or_fetch(slug).favorite_activities.to_json
    end
  end
end
