require 'roert/persistence'
class Test < Halcyon::Controller
  include Roert::Persistence

  def greet
    msg = {:interjection => 'hello', :noun => 'world', :suffix => '!'}
    obj = Sentence.new(msg)
    obj.save
    ok(obj)
  end
end
