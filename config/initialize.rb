class Halcyon::Application
  
  route do |r|
    r.match('/').to(:controller => 'server', :action => 'greet')
    
    # failover
    {:action => 'not_found'}
  end
end
