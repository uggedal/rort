require 'rort/models'
include Rort::Models

class Application < Halcyon::Controller

  def index
    ok({ :application => Rort.name, :version => Rort::VERSION })
  end
end

class Artists < Halcyon::Controller

  def show
    ok Artist.find_or_fetch(params[:id]).activities
  end
end

class Favorites < Halcyon::Controller

  def index
    ok Artist.find_or_fetch(params[:artist_id]).favorite_activities
  end
end

class Fans < Halcyon::Controller

  def index
    ok Artist.find_or_fetch(params[:artist_id]).fans
  end
end

class Friends < Halcyon::Controller

  def index
    ok Artist.find_or_fetch(params[:artist_id]).friends
  end
end
