require 'rack/request'
require 'json'

module Rort::Http
  class Api
    include Rort::Http

    def call(env)
      req = Rack::Request.new(env)

      unless req.path_info == '/'
        return [404, JSON, '']
      end

      if get?(req, 'favorites')
        if body = favorites_of(req.GET['favorites'])
          return [200, JSON, body]
        else
          return [403, JSON, '']
        end
      end

      [404, JSON, '']
    end

    def favorites_of(slug)
      artist = Rort::Models::Person.fetch(slug)
      artist ? artist.activity_list.to_json : nil
    end
  end
end
