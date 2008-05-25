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

      if get?(req, 'activities')
        if body = activities_for(req.GET['activities'])
          return [200, JSON, body]
        else
          return [403, JSON, '']
        end
      end

      if get?(req, 'favorites')
        if body = favorites_for(req.GET['favorites'])
          return [200, JSON, body]
        else
          return [403, JSON, '']
        end
      end

      [404, JSON, '']
    end

    def activities_for(slug)
      Rort::Models::Requestor.increment_or_create('experiment', slug)
      person = Rort::Models::Person.fetch(slug)
      person ? person.activity_list.to_json : nil
    end

    def favorites_for(slug)
      Rort::Models::Requestor.increment_or_create('control', slug)
      person = Rort::Models::Person.fetch(slug)
      person ? person.favorite_list.to_json : nil
    end
  end
end
