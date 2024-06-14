# frozen_string_literal: true

class XapiMiddleware::StatementCreator < ApplicationService
  attr_reader :data, :user

  def initialize(data, user = {})
    @data = data
    @user = user
  end

  def call
    verify_actor_ifi

    statement = XapiMiddleware::Statement.new(statement_json: @data.to_json)
    raise XapiMiddleware::Errors::XapiError, statement.errors.full_messages.join(", ") unless statement.valid?

    statement.save
    {status: 200, statement: statement}
  end

  private

  # Ensure that an actor inverse functional identifier (IFI) is present.
  #
  # @raise [XapiMiddleware::Errors::XapiError] If the actor is invalid
  def verify_actor_ifi
    is_valid = XapiMiddleware::Actor.validate_actor(@data[:actor])

    # Attempt to set the mbox from the optional user param
    if !is_valid && @user[:email].present?
      data_actor ||= @data[:actor].merge(mbox: "mailto:#{@user.email}")
      @data[:actor] = data_actor
    end

    actor = XapiMiddleware::Actor.new(@data[:actor])
    raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.actor_ifi_must_be_present") unless actor.valid?
  end
end
