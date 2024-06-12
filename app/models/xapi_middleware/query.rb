# frozen_string_literal: true

class XapiMiddleware::Query
  # Query statements by actor's email
  #
  # @param actor_email [String] The email address of the actor
  # @return [ActiveRecord::Relation] The statements associated with the actor
  # @raise [ArgumentError] If the email format is invalid
  def self.actor_by_email(actor_email)
    raise ArgumentError, I18n.t("xapi_middleware.errors.malformed_email", name: actor_email) unless 
      actor_email.match?(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/)

    XapiMiddleware::Statement.where(actor_mbox: "mailto:#{actor_email.html_safe}")
  end

  # Query statements by actor's mbox
  #
  # @param actor_mbox [String] The mbox identifier of the actor
  # @return [ActiveRecord::Relation] The statements associated with the actor
  # @raise [ArgumentError] If the mbox format is invalid
  def self.actor_by_mbox(actor_mbox)
    raise ArgumentError, I18n.t("xapi_middleware.errors.malformed_mbox", name: actor_mbox) unless 
      actor_mbox.match?(/\Amailto:([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/)

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

  def self.statements_per_month(resources, year = Date.current.year, month = Date.current.month)
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month

    dates_for_current_month = (start_date..end_date).to_a
    graph_data = resources.where(created_at: start_date..end_date).group("DATE(created_at)").count

    # Create a hash with default value 0 for each date of the current month
    complete_data = dates_for_current_month.index_with { 0 }
    # Merge the existing data with the complete data and format
    complete_data.merge(graph_data).map do |date, count|
      {date: date.strftime("%Y-%m-%d"), value: count}
    end
  end
end
