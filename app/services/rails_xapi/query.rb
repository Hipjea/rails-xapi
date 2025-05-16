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
      raise RailsXapi::Errors::XapiError,
            I18n.t("rails_xapi.errors.query_not_available")
    end
  end

  private

  # @param id [Integer] The ID of the statement
  # @return [RailsXapi::Statement] The statement record
  def statement(id)
    RailsXapi::Statement.includes(%i[actor verb object context result]).find(id)
  end

  # Get a hash of all statements concerning the actors emails and object_id.
  #
  # @param object_id [String] The object IRI
  # @param actor_emails [Array<String>] List of actor emails
  # @return [ActiveRecord::Relation] Statements matching criteria
  # @raise [ArgumentError] If no emails provided
  def statements_by_actor_emails_and_object_id(object_id, actor_emails = [])
    unless actor_emails.any?
      raise ArgumentError, I18n.t("rails_xapi.errors.malformed_email")
    end

    mailto_emails =
      actor_emails.map do |email|
        email.start_with?("mailto:") ? email : "mailto:#{email}"
      end

    RailsXapi::Statement.includes(
      [:actor, { actor: :account }, :verb, :object, :context, :result]
    ).where(actor: { mbox: mailto_emails }, object: { id: object_id })
  end

  # Get a list of all unique verb_id values
  #
  # @return [Array<Integer>] Unique verb IDs
  def verb_ids
    RailsXapi::Statement.distinct.pluck(:verb_id)
  end

  # Get a list of all unique verb_display values
  #
  # @return [Array<String>] Unique verb display values
  def verb_displays
    RailsXapi::Statement.includes(:verb).distinct.pluck(:display)
  end

  # Get a hash of all unique verbs with verb_id as keys and verb_display as values.
  #
  # @return [Hash{Integer => String}] verb_id => verb_display mapping
  def verbs
    RailsXapi::Statement.includes(:verb).distinct.pluck(:verb_id, :display)
  end

  # Query statements by actor's email
  #
  # @param actor_email [String] Actor email address
  # @return [ActiveRecord::Relation] Statements from this actor
  # @raise [ArgumentError] If email format is invalid
  def actor_by_email(actor_email)
    unless actor_email.match?(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/)
      raise ArgumentError,
            I18n.t("rails_xapi.errors.malformed_email", name: actor_email)
    end

    RailsXapi::Statement.includes(%i[actor verb object]).where(
      actor: {
        mbox: "mailto:#{actor_email}"
      }
    )
  end

  # Query statements by actor's mbox
  #
  # @param actor_mbox [String] mbox (e.g., "mailto:user@example.com")
  # @return [ActiveRecord::Relation] Statements for this mbox
  # @raise [ArgumentError] If mbox format is invalid
  def actor_by_mbox(actor_mbox)
    unless actor_mbox.match?(
             /\Amailto:([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/
           )
      raise ArgumentError,
            I18n.t("rails_xapi.errors.malformed_mbox", name: actor_mbox)
    end

    RailsXapi::Statement.includes(%i[actor verb object]).where(
      actor: {
        mbox: actor_mbox
      }
    )
  end

  # Query statements by actor's account homepage
  #
  # @param actor_account_homepage [String] Account homepage URL
  # @return [ActiveRecord::Relation] Statements for this account
  def actor_by_account_homepage(actor_account_homepage)
    RailsXapi::Statement.includes(%i[actor verb object]).where(
      actor: {
        account: {
          home_page: actor_account_homepage
        }
      }
    )
  end

  # Query statements by actor's openid
  #
  # @param actor_openid [String] The openID
  # @return [ActiveRecord::Relation] Statements for this openID
  def actor_by_openid(actor_openid)
    RailsXapi::Statement.includes(%i[actor verb object]).where(
      actor: {
        openid: actor_openid
      }
    )
  end

  # Query statements by actor's mbox_sha1sum
  #
  # @param actor_mbox_sha1sum [String] SHA1 hash of actor's mbox
  # @return [ActiveRecord::Relation] Statements for this mbox_sha1sum identifier
  def actor_by_mbox_sha1sum(actor_mbox_sha1sum)
    RailsXapi::Statement.includes(%i[actor verb object]).where(
      actor: {
        mbox_sha1sum: actor_mbox_sha1sum
      }
    )
  end

  # Query statements by actor's identifier per month
  #
  # @param actor_identifier [Hash] One key-value pair representing the identifier
  # @param year [Integer] Year (defaults to current)
  # @param month [Integer] Month (defaults to current)
  # @return [ActiveRecord::Relation] Statements in the given month
  # @raise [ArgumentError] If identifier is empty
  def user_statements_per_month(
    actor_identifier = {},
    year = Date.current.year,
    month = Date.current.month
  )
    if actor_identifier.first.empty?
      raise ArgumentError,
            I18n.t(
              "rails_xapi.errors.exactly_one_actor_identifier_must_be_provided"
            )
    end

    identifier_key, identifier_value = actor_identifier.first
    start_date, end_date =
      self.class.send(:generate_start_date_end_date, year, month)
    RailsXapi::Statement
      .joins(:actor)
      .where(
        actor: {
          identifier_key => identifier_value
        },
        created_at: start_date..end_date
      )
      .group(:id)
  end

  # Take a collection of records and generate a number of records created each day of the given month
  #
  # @param resources [ActiveRecord::Relation] Statement records
  # @param year [Integer] Year for filtering
  # @param month [Integer] Month for filtering
  # @return [ActiveRecord::Relation] Grouped statements by date
  def per_month(resources, year = Date.current.year, month = Date.current.month)
    start_date, end_date =
      self.class.send(:generate_start_date_end_date, year, month)
    resources.where(
      "rails_xapi_statements.created_at": start_date..end_date
    ).group("DATE(rails_xapi_statements.created_at)")
  end

  # @param data [Array<RailsXapi::Statement>] Statement list
  # @param year [Integer] Year for generating the range
  # @param month [Integer] Month for generating the range
  # @return [Array<Hash>] Array of date/count pairs
  def month_graph_data(
    statements,
    year = Date.current.year,
    month = Date.current.month
  )
    start_date, end_date =
      self.class.send(:generate_start_date_end_date, year, month)
    month_dates = (start_date..end_date).to_a

    # Create a hash with default value 0 for each date of the current month
    complete_data = month_dates.index_with { 0 }

    # Transform data to count occurrences for each date
    data_by_date =
      statements
        .group_by { |statement| statement.created_at.to_date }
        .transform_values(&:count)

    # Merge the existing data with the complete data and format
    complete_data
      .merge(data_by_date)
      .map { |date, count| { date: date.strftime("%Y-%m-%d"), value: count } }
  end
end
