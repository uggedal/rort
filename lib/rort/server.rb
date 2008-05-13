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

      elsif get?(req, 'download')
        username = req.GET['download']

        if validate_user(username)
          [200, HTML, userscript]
        else
          [200, HTML, username_form("Ugyldig bruker: #{username}")]
        end

      elsif get?(req, 'favorites') && body = favorites_of(req.GET['favorites'])
        [200, JSON, body]
      else
        [404, JSON, '']
      end
    end

    def username_form(msg='')
      <<-EOS
        <html>
          <head>
            <title>Last ned Ur&oslash;rt bruker-script</title>
          </head>
          <body>
            <h1>Last ned Ur&oslash;rt bruker-script</h1>
            <p style="color:red;">#{msg}</p>
            <p>
              Oppgi ditt brukernavn hos Ur&oslash;rt slik at vi kan
              gj&oslash;re klar data for deg.
            </p>
            <form action="/" method="get">
              <label for="download">Brukernavn:</label>
              <input type="text" name="download" id="download">
              <input type="submit" value="Last ned!">
            </form>
          </body>
        </html>
      EOS
    end

    def validate_user(username)
      Rort::Models::Person.fetch(username)
    end

    def userscript
      "==UserScript=="
    end

    def favorites_of(slug)
      artist = Rort::Models::Person.fetch(slug)
      artist ? artist.favorite_activities.to_json : nil
    end
  end
end
