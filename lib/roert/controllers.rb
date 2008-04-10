require 'roert/models'
include Roert::Models

class Application < Halcyon::Controller; end

class Test < Application

  def greet
    msg = {:interjection => 'hello', :noun => 'world', :suffix => '!'}
    obj = Sentence.new(msg)
    obj.save
    ok(obj)
  end
end
