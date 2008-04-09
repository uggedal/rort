class Halcyon::Application
  
  route do |r|
    r.match('/greet').to(:controller => 'test', :action => 'greet')
    
    # failover
    {:action => 'not_found'}
  end
end
