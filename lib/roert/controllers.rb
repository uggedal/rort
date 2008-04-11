require 'roert/models'
include Roert::Models

class Application < Halcyon::Controller
  def index
    ok({ :application => Roert.name, :version => Roert::VERSION })
  end
end

class Artists < Halcyon::Controller

  def show
    ok(Artist.find_or_fetch(params[:id]))
  end
end
