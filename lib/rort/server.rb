require 'rack/request'
require 'rort/models'
require 'json'

module Rort
  class Server

    JSON = { 'Content-Type' => 'application/json' }
    HTML = { 'Content-Type' => 'text/html' }

    def call(env)
      req = Rack::Request.new(env)

      def get?(req, key)
        req.get? && req.GET.any? && req.GET.key?(key)
      end

      if req.get? && req.GET.empty?
        [200, HTML, username_form]
      elsif get?(req, 'username')
        [200, HTML, req.GET['username']]
      elsif get?(req, 'favorites') && body = favorites_of(req.GET['favorites'])
        [200, JSON, body]
      else
        [404, JSON, '']
      end
    end

    def username_form
      <<-EOS
        <html>
          <head>
            <title>Last ned Urort bruker-script</title>
          </head>
          <body>
            <h1>Last ned Urort bruker-script</h1>
            <p>
              Oppgi ditt brukernavn hos Urort slik at vi kan gjoere
              klar data for deg.
            </p>
            <form action="/" method="get">
              <label for="username">Brukernavn:</label>
              <input type="text" name="username" id="username">
              <input type="submit" value="Last ned!">
            </form>
          </body>
        </html>
      EOS
    end

    def favorites_of(slug)
      artist = Rort::Models::Person.fetch(slug)
      artist ? artist.favorite_activities.to_json : nil
    end
  end
end
