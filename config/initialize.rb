class Halcyon::Application
  
  route do |r|
    r.match('/').to(:controller => 'application')
    r.resources :artists do |a|
      a.resources :favorites
      a.resources :fans
      a.resources :friends
    end
  end
end
