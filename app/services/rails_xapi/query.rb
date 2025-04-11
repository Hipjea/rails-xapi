# frozen_string_literal: true

# This class manages the query interface for verbs.
class RailsXapi::Query < ApplicationService
  def initialize(query:)
    @query = query
  end

  def self.call(query:)
    new(query: query).call
  end

  def call
    if respond_to?(@query, true)
      send(@query)
    else
      raise RailsXapi::Errors::XapiError, I18n.t("rails_xapi.errors.query_not_available")
    end
  end

  private

  # Get a list of all unique verb_id values
  #
  # @return [ActiveRecord::Relation] The unique verb_id values
  def verb_ids
    RailsXapi::Statement.distinct.pluck(:verb_id)
  end

  # Get a list of all unique verb_display values
  #
  # @return [ActiveRecord::Relation] The unique verb_display values
  def verb_displays
    RailsXapi::Statement.includes(:verb).distinct.pluck(:display)
  end

  # Get a hash of all unique verbs with verb_id as keys and verb_display as values.
  #
  # @return [Hash] A hash where keys are verb_id and values are verb_display.
  def verbs
    RailsXapi::Statement.includes(:verb).distinct.pluck(:verb_id, :display)
  end

  # Get a hash of all statements concerning the actors emails and object_id.
  #
  # @param [Hash] actor_emails
  # @param [String] object_id The object IRI
  # @return [Hash] A hash of statements.
  def statements_by_actor_emails_and_object_id(object_id, actor_emails = [])
    raise ArgumentError, I18n.t("rails_xapi.errors.malformed_email") unless actor_emails.any?

    mailto_emails = actor_emails.map do |email|
      email.start_with?("mailto:") ? email : "mailto:#{email}"
    end

    RailsXapi::Statement.includes([:actor, {actor: :account}, :verb, :object, :result])
      .where(actor: {mbox: mailto_emails}, object: {id: object_id})
  end
end
