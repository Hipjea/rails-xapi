# frozen_string_literal: true

# This class manages the query interface for verbs.
class RailsXapi::Query < ApplicationService
  def initialize(query:, args: [])
    @query = query
    @args = args
  end

  def self.call(query:, args: [])
    new(query: query, args: args).call
  end

  def call
    if respond_to?(@query, true)
      send(@query, *@args)
    else
      raise RailsXapi::Errors::XapiError, I18n.t("rails_xapi.errors.query_not_available")
    end
  end

  private

  # Set the start_date to the first day of the given month and year,
  # and the end_date to the last day of the givenn month.
  private_class_method def self.generate_start_date_end_date(year, month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    [start_date, end_date]
  end

  def statement(id)
    RailsXapi::Statement.includes([:actor, :verb, :object, :context, :result]).find(id)
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

    RailsXapi::Statement.includes([:actor, {actor: :account}, :verb, :object, :context, :result])
      .where(actor: {mbox: mailto_emails}, object: {id: object_id})
  end

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

  # Query statements by actor's email
  #
  # @param actor_email [String] The email address of the actor
  # @return [ActiveRecord::Relation] The statements associated with the actor
  # @raise [ArgumentError] If the email format is invalid
  def actor_by_email(actor_email)
    unless actor_email.match?(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/)
      raise ArgumentError, I18n.t("rails_xapi.errors.malformed_email", name: actor_email)
    end

    RailsXapi::Statement.includes([:actor, :verb, :object]).where(actor: {mbox: "mailto:#{actor_email}"})
  end

  # Query statements by actor's mbox
  #
  # @param actor_mbox [String] The mbox identifier of the actor
  # @return [ActiveRecord::Relation] The statements associated with the actor
  # @raise [ArgumentError] If the mbox format is invalid
  def actor_by_mbox(actor_mbox)
    unless actor_mbox.match?(/\Amailto:([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/)
      raise ArgumentError, I18n.t("rails_xapi.errors.malformed_mbox", name: actor_mbox)
    end

    RailsXapi::Statement.includes([:actor, :verb, :object]).where(actor: {mbox: actor_mbox})
  end

  # Query statements by actor's account homepage
  #
  # @param actor_account_homepage [String] The account home page URL of the actor
  # @return [ActiveRecord::Relation] The statements associated with the actor
  def actor_by_account_homepage(actor_account_homepage)
    RailsXapi::Statement.includes([:actor, :verb, :object]).where(actor: {account: {home_page: actor_account_homepage}})
  end

  # Query statements by actor's openid
  #
  # @param actor_id [String] The openID of the actor
  # @return [ActiveRecord::Relation] The statements associated with the actor
  def actor_by_openid(actor_openid)
    RailsXapi::Statement.includes([:actor, :verb, :object]).where(actor: {openid: actor_openid})
  end

  # Query statements by actor's mbox_sha1sum
  #
  # @param actor_id [String] The mbox_sha1sum of the actor
  # @return [ActiveRecord::Relation] The statements associated with the actor
  def actor_by_mbox_sha1sum(actor_mbox_sha1sum)
    RailsXapi::Statement.includes([:actor, :verb, :object]).where(actor: {mbox_sha1sum: actor_mbox_sha1sum})
  end

  # Query statements by actor's identifier per month
  #
  # @param actor_identifier [String] The mbox_sha1sum of the actor
  # @param year [Integer] The year integer value
  # @param month [Integer] The month integer value
  # @return [ActiveRecord::Relation] The statements associated with the actor
  def user_statements_per_month(actor_identifier = {}, year = Date.current.year, month = Date.current.month)
    raise ArgumentError, I18n.t("rails_xapi.errors.exactly_one_actor_identifier_must_be_provided") if actor_identifier.first.empty?

    identifier_key, identifier_value = actor_identifier.first
    start_date, end_date = generate_start_date_end_date(year, month)
    RailsXapi::Statement.joins(:actor)
      .where(actor: {identifier_key => identifier_value}, created_at: start_date..end_date)
      .group(:id)
  end

  # Takes a collection of records and generate a number of records created each day of the given month
  #
  # @param resources [ActiveRecord::Relation] The statement query to complement
  # @param year [Integer] The year integer value
  # @param month [Integer] The month integer value
  # @return [ActiveRecord::Relation] The statements associated with the actor
  def per_month(resources, year = Date.current.year, month = Date.current.month)
    start_date, end_date = generate_start_date_end_date(year, month)
    resources.where("rails_xapi_statements.created_at": start_date..end_date)
      .group("DATE(rails_xapi_statements.created_at)")
  end

  def month_graph_data(data, year = Date.current.year, month = Date.current.month)
    start_date, end_date = generate_start_date_end_date(year, month)
    month_dates = (start_date..end_date).to_a

    # Create a hash with default value 0 for each date of the current month
    complete_data = month_dates.index_with { 0 }

    # Transform data to count occurrences for each date
    data_by_date = data.group_by { |statement| statement.created_at.to_date }
      .transform_values(&:count)

    # Merge the existing data with the complete data and format
    complete_data.merge(data_by_date).map do |date, count|
      {date: date.strftime("%Y-%m-%d"), value: count}
    end
  end
end
