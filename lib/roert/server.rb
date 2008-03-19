module Roert

  require 'halcyon/server'

  class Server < Halcyon::Server::Base
    route {|r| r.match('/').to(:action => 'greet') }

    def greet
      msg = {:interjection => 'hello', :noun => 'world', :suffix => '!'}
      ok(msg)
    end
  end
end
