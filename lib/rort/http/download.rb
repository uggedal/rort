require 'rack/request'

module Rort::Http
  class Download
    include Rort::Http

    USR_SCRIPT = '/rort.user.js'

    def call(env)
      req = Rack::Request.new(env)

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
        email = req.GET['download']
        respondent = Rort::Models::Respondent.find_or_create(:email => email)

        if respondent.errors.empty?
          return [200, HTML, download_link]
        else
          return [200, HTML, download_form("Ugyldig epost: #{email}")]
        end
      end

      [404, HTML, '']
    end

    def userscript
      File.read(File.join(Rort.root, 'ext', 'rort.user.js'))
    end

    def html_template(body)
      <<-EOS
        <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
          "http://www.w3.org/TR/html4/strict.dtd">
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
          Oppgi din epost adresse<sup>*</sup> for &aring; laste
          ned v&aring;r utvidelse av Ur&oslash;rt.
        <p>
        <form action="/" method="get">
          <label for="download">Epost:</label>
          <input type="text" name="download" id="download">
          <input type="submit" value="Last ned!">
        </form>
        <p>
          <sup>*</sup> Adressen brukes kun for &aring; identifisere
          hvem som har tatt i bruk v&aring;r utvidelse av Ur&oslash;rt.
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
          Ta turen over til
          <a href="http://nrk.no/urort">Ur&oslash;rt</a> og logg deg inn for
          &aring; se hva som er nytt fra dine favoritter.
        </p>
      EOS
      html_template(body)
    end

  end
end
