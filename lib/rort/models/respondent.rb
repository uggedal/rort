module Rort::Models

  class Respondent < Sequel::Model

    set_schema do
      primary_key :id
      text        :email,    :null => false, :unique => true
      text        :group,    :null => false
      text        :slug
      integer     :requests, :default => 0
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
      Respondent.any? ? Respondent.order(:id).last.group : 'control'
    end

    def self.next_group(group = previous_group)
      case group
      when 'experiment'
        'control'
      when 'control'
        'experiment'
      end
    end

    def self.increment(email, slug)
      respondent = Respondent.find(:email => email)
      return nil unless respondent

      respondent.requests = respondent.requests + 1
      respondent.slug = slug unless respondent.slug
      respondent.save
      respondent
    end
  end

  Respondent.create_table unless Respondent.table_exists?
end
