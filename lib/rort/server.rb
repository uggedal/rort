require 'rack/request'
require 'rort/models'
require 'json'

module Rort
  class Server

    USR_SCRIPT = '/rort.user.js'

    JSON  = { 'Content-Type' => 'application/json' }
    JS    = { 'Content-Type' => 'application/javascript' }
    HTML  = { 'Content-Type' => 'text/html' }
    REDIR = { 'Location' => USR_SCRIPT }

    def call(env)
      req = Rack::Request.new(env)

      def get?(req, key)
        req.get? && req.GET.any? && req.GET.key?(key)
      end

      if req.path_info == USR_SCRIPT
        [200, JS, userscript]

      elsif req.get? && req.GET.empty?
        [200, HTML, download_form]

      elsif get?(req, 'download')
        username = req.GET['download']

        if validate_user(username)
          collect_activities_in_background(username)
          [303, REDIR, '']
        else
          [200, HTML, download_form("Ugyldig bruker: #{username}")]
        end

      elsif get?(req, 'favorites') && body = favorites_of(req.GET['favorites'])
        [200, JSON, body]
      else
        [404, JSON, '']
      end
    end

    def download_form(msg='')
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
              gj&oslash;re klar informasjon om dine favoritter.
              Brukernvavnet brukes kun for &aring; finne ut hvilke
              artister du favoriserer.
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

    def collect_activities_in_background(username)
      Rort::Queue.push(username)
    end

    def userscript
      File.read(File.join(Rort.root, 'ext', 'rort.user.js'))
    end

    def favorites_of(slug)
      artist = Rort::Models::Person.fetch(slug)
      artist ? artist.favorite_activities.to_json : nil
    end
  end
end
