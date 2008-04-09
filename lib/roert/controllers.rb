require 'roert/persistence'
include Roert

class Test < Halcyon::Controller

  def greet
    msg = {:interjection => 'hello', :noun => 'world', :suffix => '!'}
    obj = Persistence::Sentence.new(msg)
    obj.save
    ok(obj)
  end
end
