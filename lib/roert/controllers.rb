require 'roert/models'
include Roert::Models

class Application < Halcyon::Controller
  def index
    ok({ :application => Roert.name, :version => Roert::VERSION })
  end
end
