class Halcyon::Application
  
  route do |r|
    r.match('/').to(:controller => 'application')
    r.default_routes
  end
end
