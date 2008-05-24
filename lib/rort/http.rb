module Rort::Http
  JSON  = { 'Content-Type' => 'application/json' }
  JS    = { 'Content-Type' => 'application/javascript' }
  HTML  = { 'Content-Type' => 'text/html' }


  def get?(req, key)
    req.get? && req.GET.any? && req.GET.key?(key)
  end
end

require 'rort/http/api'
require 'rort/http/download'
