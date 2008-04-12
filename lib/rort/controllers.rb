require 'rort/models'
include Rort::Models

class Application < Halcyon::Controller
  def index
    ok({ :application => Rort.name, :version => Rort::VERSION })
  end
end

class Artists < Halcyon::Controller

  def show
    ok(Artist.find_or_fetch(params[:id]))
  end
end
