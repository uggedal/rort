class Halcyon::Application
  
  route do |r|
    r.match('/').to(:controller => 'controller', :action => 'greet')
    
    # failover
    {:action => 'not_found'}
  end
end
