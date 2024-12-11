# frozen_string_literal: true

# This class manages the query interface for statements.
class RailsXapi::QueryStatement < ApplicationService
  def self.by_actor_emails_and_object_id(actor_emails = [], object_id)
    raise ArgumentError, I18n.t("rails_xapi.errors.malformed_email") unless actor_emails.any?

    mailto_emails = actor_emails.map do |email|
      email.start_with?("mailto:") ? email : "mailto:#{email}"
    end

    RailsXapi::Statement.includes([:actor, {actor: :account}, :verb, :object, :result])
      .where(actor: {mbox: mailto_emails}, object: {id: object_id})
  end
end
