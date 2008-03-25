class Controller < Halcyon::Controller

  def greet
    msg = {:interjection => 'hello', :noun => 'world', :suffix => '!'}
    ok(msg)
  end
end
