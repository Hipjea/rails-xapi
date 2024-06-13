# frozen_string_literal: true

# This class manages the query interface.
class XapiMiddleware::Query
  # Query statements by actor's email
  #
  # @param actor_email [String] The email address of the actor
  # @return [ActiveRecord::Relation] The statements associated with the actor
  # @raise [ArgumentError] If the email format is invalid
  def self.actor_by_email(actor_email)
    unless actor_email.match?(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/)
      raise ArgumentError, I18n.t("xapi_middleware.errors.malformed_email", name: actor_email)
    end

    XapiMiddleware::Statement.where(actor_mbox: "mailto:#{actor_email}")
  end

  # Query statements by actor's mbox
  #
  # @param actor_mbox [String] The mbox identifier of the actor
  # @return [ActiveRecord::Relation] The statements associated with the actor
  # @raise [ArgumentError] If the mbox format is invalid
  def self.actor_by_mbox(actor_mbox)
    unless actor_mbox.match?(/\Amailto:([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/)
      raise ArgumentError, I18n.t("xapi_middleware.errors.malformed_mbox", name: actor_mbox)
    end

    XapiMiddleware::Statement.where(actor_mbox: actor_mbox)
  end

  # Query statements by actor's account homepage
  #
  # @param actor_account_homepage [String] The account home page URL of the actor
  # @return [ActiveRecord::Relation] The statements associated with the actor
  def self.actor_by_account_homepage(actor_account_homepage)
    XapiMiddleware::Statement.where(actor_account_homepage: actor_account_homepage)
  end

  # Query statements by actor's openid
  #
  # @param actor_id [String] The openID of the actor
  # @return [ActiveRecord::Relation] The statements associated with the actor
  def self.actor_by_openid(actor_openid)
    XapiMiddleware::Statement.where(actor_openid: actor_openid)
  end

  # Query statements by actor's mbox_sha1sum
  #
  # @param actor_id [String] The mbox_sha1sum of the actor
  # @return [ActiveRecord::Relation] The statements associated with the actor
  def self.actor_by_mbox_sha1sum(actor_mbox_sha1sum)
    XapiMiddleware::Statement.where(actor_mbox_sha1sum: actor_mbox_sha1sum)
  end

  # Query statements by actor's identifier per month
  #
  # @param actor_identifier [String] The mbox_sha1sum of the actor
  # @param year [Integer] The year integer value
  # @param month [Integer] The month integer value
  # @return [ActiveRecord::Relation] The statements associated with the actor
  def self.user_statements_per_month(actor_identifier = {}, year = Date.current.year, month = Date.current.month)
    raise ArgumentError, I18n.t("xapi_middleware.errors.exactly_one_actor_identifier_must_be_provided") if actor_identifier.keys.size != 1

    identifier_key, identifier_value = actor_identifier.first
    start_date, end_date = generate_start_date_end_date(year, month)
    month_dates = (start_date..end_date).to_a
    graph_data = XapiMiddleware::Statement.where(identifier_key => identifier_value, created_at: start_date..end_date)
      .group("DATE(created_at)")
      .count

    return generate_month_graph_data(month_dates, graph_data)
  end

  # Takes a collection of records and generate a number of records created each day of the given month
  #
  # @param resources [ActiveRecord::Relation] The statement query to complement
  # @param year [Integer] The year integer value
  # @param month [Integer] The month integer value
  # @return [ActiveRecord::Relation] The statements associated with the actor
  def self.per_month(resources, year = Date.current.year, month = Date.current.month)
    start_date, end_date = generate_start_date_end_date(year, month)
    month_dates = (start_date..end_date).to_a
    graph_data = resources.where(created_at: start_date..end_date).group("DATE(created_at)").count

    return generate_month_graph_data(month_dates, graph_data)
  end

  private

  # Set the start_date to the first day of the given month and year,
  # and the end_date to the last day of the givenn month.
  def self.generate_start_date_end_date(year, month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    return start_date, end_date
  end

  def self.generate_month_graph_data(month_dates, graph_data)
    # Create a hash with default value 0 for each date of the current month
    complete_data = month_dates.index_with { 0 }

    # Merge the existing data with the complete data and format
    complete_data.merge(graph_data).map do |date, count|
      {date: date.strftime("%Y-%m-%d"), value: count}
    end
  end
end
