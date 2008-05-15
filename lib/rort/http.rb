require 'rack/request'
require 'rort/models'
require 'json'

module Rort
  class Http

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
        return [200, JS, userscript]
      end

      unless req.path_info == '/'
        return [404, HTML, '']
      end

      if req.get? && req.GET.empty?
        return [200, HTML, download_form]
      end

      if get?(req, 'download')
        username = req.GET['download']

        if validate_user(username)
          collect_activities_in_background(username)
          return [200, HTML, download_link]
        else
          return [200, HTML, download_form("Ugyldig adresse: #{username}")]
        end
      end

      if get?(req, 'favorites')
        if body = favorites_of(req.GET['favorites'])
          return [200, JSON, body]
        else
          return [403, JSON, '']
        end
      end

      [404, HTML, '']
    end

    def html_template(body)
      <<-EOS
        <html>
          <head>
            <title>Last ned Ur&oslash;rt bruker-script</title>
            <style type="text/css">
              body { width: 40em; }
            </style>
          </head>
          <body>
            <h1>Last ned Ur&oslash;rt bruker-script</h1>
            #{body}
          </body>
        </html>
      EOS
    end

    def download_form(msg='')
      body = <<-EOS
        <p style="color:red;">#{msg}</p>
        <p>
          For &aring; installere dette bruker-scriptet m&aring; du benytte
          nettleseren <a href="http://firefox.no">Firefox</a> og
          installere
          <a href="https://addons.mozilla.org/en-US/firefox/addon/748">
            Greasemonkey</a>,
          et tillegg som gj&oslash;r det mulig &aring; endre
          eksisterende nettsider.
        </p>
        <p>
          Oppgi din Ur&oslash;rt adresse<sup>*</sup> slik at vi kan
          gj&oslash;re klar informasjon om dine favoritter.
          Din Ur&oslash;rt adresse finner du p&aring;
          <a href="http://www11.nrk.no/urort/myuser2/editProfile.aspx">
            redigering av Ur&oslash;rt  profil
          </a>
          i feltet <em>Lenke til Ur&oslash;rt</em>.
          Du trenger bare &aring; oppgi siste delen av adressen.
        <p>
        <form action="/" method="get">
          <label for="download">Adresse:</label>
          <input type="text" name="download" id="download">
          <input type="submit" value="Last ned!">
        </form>
        <p>
          <sup>*</sup> Adressen brukes kun for &aring; identifisere hvilke
          artister du favoriserer.
        </p>
      EOS
      html_template(body)
    end

    def download_link
      body = <<-EOS
        <p>
          Bruker-scriptet kan n&aring;
          <a href="/rort.user.js">installeres</a>.
        </p>
      EOS
      html_template(body)
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
