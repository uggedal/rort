require 'rack/request'

module Rort::Http
  class Download
    include Rort::Http

    SCRIPT = {:experiment => '/rort.user.js',
              :control => '/urort.user.js'}

    def call(env)
      req = Rack::Request.new(env)


      if req.path_info =~ /^\/install\//
        email, file = req.path_info.
          scan(/\/install\/([\w._%+-@]+)\/([a-z.]+)/).flatten
        return [200, JS, userscript(file, email)]
      end

      unless req.path_info == '/'
        return [404, HTML, '']
      end

      if req.post?
        email = req.POST['email']
        respondent = Rort::Models::Respondent.find_or_create(:email => email)

        if respondent.errors.empty?
          return [200, HTML, install_link(respondent.email, respondent.group)]
        else
          return [200, HTML, download_form("Ugyldig epost: #{email}")]
        end
      end

      if req.get?
        return [200, HTML, download_form]
      end

      [404, HTML, '']
    end

    def userscript(file, email)
      File.read(File.join(Rort.root, 'ext', file)).gsub(/#\/#\/#\/#\/#\//,
                                                        email)
    end

    def html_template(body)
      <<-EOS
        <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
          "http://www.w3.org/TR/html4/strict.dtd">
        <html>
          <head>
            <title>
              Installere ekstra funksjonalitet p&aring; Ur&oslash;rt
            </title>
            <link rel="stylesheet"
                  href="/doc/style.css"
                  type="text/css"
                  media="screen">
          </head>
          <body id="main">
            #{body}
          </body>
        </html>
      EOS
    end

    def download_form(msg='')
      body = <<-EOS
        <h1>
          Installere ekstra funksjonalitet p&aring; Ur&oslash;rt
        </h1>
        <p style="color:red;">#{msg}</p>
        <p>
          For &aring; installere ekstra funksjonalitet p&aring;
          Ur&oslash;rt m&aring; du benytte
          nettleseren <a href="http://firefox.no">Firefox</a> og
          ha installert
          <a href="/doc/install.html" target="_blank">Greasemonkey</a>,
          et tillegg som gj&oslash;r det mulig &aring; endre
          eksisterende nettsider.
        </p>
        <p>
          Oppgi din epost adresse<sup>*</sup> for &aring; laste
          ned v&aring;r utvidelse av Ur&oslash;rt.
        <p>
        <form action="/" method="post">
          <label for="email">Epost:</label>
          <input type="text" name="email" id="email">
          <input type="submit" value="Registrer">
        </form>
        <p>
          <sup>*</sup> Adressen brukes kun for &aring; identifisere
          hvem som har tatt i bruk v&aring;r utvidelse av Ur&oslash;rt.
        </p>
      EOS
      html_template(body)
    end

    def install_link(email, type)
      body = <<-EOS
        <h1>
          Installere ekstra funksjonalitet p&aring; Ur&oslash;rt:
          Greasemonkey tillegg for Ur&oslash;rt
        </h1>
        <p>
          Bruker-scriptet kan n&aring;
          <a href="/install/#{email}#{SCRIPT[type.to_sym]}">installeres</a>.
        </p>
        <p>
          Etter 3 sekunder kan man klikke p&aring; <em>Install</em>
          for &aring; installere Ur&oslash;rt bruker-scriptet.
          <img src="/doc/install_5.png" alt="">
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
