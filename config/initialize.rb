class Halcyon::Application
  
  route do |r|
    r.match('/').to(:controller => 'application')
    r.resources :artists
  end
end
