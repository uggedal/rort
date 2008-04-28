module Rort::Models

  class User

    def initialize(slug, external=nil)
      @slug = slug
      @external = external
    end

    attr_reader :slug
    attr_writer :name

    def external
      @external ||= Rort::External::Artist.as(slug)
    end

    def id
      @name ||= external.id
    end

    def name
      @name ||= external.name
    end

    private

      def reverse_sort_by_datetime(items)
        items.sort { |a,b| b[:datetime] <=> a[:datetime] }
      end
  end
end
