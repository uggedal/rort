module Rort::Models
  require 'sequel'

  if $TESTING
    DB = Sequel.sqlite
  else
    DB = Sequel.sqlite File.expand_path('../../../../rort.db', __FILE__)
  end

  class Respondent < Sequel::Model
    set_schema do
      primary_key :email
      text        :email, :unique => true
      text        :group
      timestamp   :created_at
    end

    before_create do
      self.created_at = Time.now
      self.group = Respondent.next_group
    end

    validates do
      format_of :email, :with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
    end

    def self.previous_group
      Respondent.any? ? Respondent.order(:created_at).last.group : 'control'
    end

    def self.next_group(group = previous_group)
      case group
      when 'experiment'
        'control'
      when 'control'
        'experiment'
      end
    end
  end

  Respondent.create_table unless Respondent.table_exists?
end