require 'rack/request'
require 'json'

module Rort::Http
  class Api
    include Rort::Http

    def call(env)
      req = Rack::Request.new(env)

      if get?(req, 'email') && get?(req, 'slug')

        if req.path_info == '/activities'

          if body = activities_for(req.GET['email'], req.GET['slug'])
            return [200, JSON, body]
          else
            return [403, JSON, '']
          end
        end

        if req.path_info == '/favorites'

          if body = favorites_for(req.GET['email'], req.GET['slug'])
            return [200, JSON, body]
          else
            return [403, JSON, '']
          end
        end
      end

      [404, JSON, '']
    end

    def activities_for(email, slug)
      Rort::Models::Respondent.increment(email, slug)
      person = Rort::Models::Person.fetch(slug)
      person ? person.activity_list.to_json : nil
    end

    def favorites_for(email, slug)
      Rort::Models::Respondent.increment(email, slug)
      person = Rort::Models::Person.fetch(slug)
      person ? person.favorite_list.to_json : nil
    end
  end
end
