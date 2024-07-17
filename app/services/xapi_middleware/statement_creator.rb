# frozen_string_literal: true

class XapiMiddleware::StatementCreator < ApplicationService
  attr_reader :data, :user

  def initialize(data, user = {})
    @data = data
    @user = user
  end

  def call
    # Build the actor
    actor = build_actor

    # Find or create the verb
    verb = XapiMiddleware::Verb.find_or_create_by(id: @data[:verb][:id]) do |v|
      v.display = @data[:verb][:display]
    end

    p "*" * 90
    p @data[:object]
    p "*" * 90

    # Find or create the object
    object = XapiMiddleware::Object.find_or_create_by(id: @data[:object][:id]) do |obj|
      obj.object_type = @data[:object][:object_type]
    end

    # Find or create the activity definition for the object
    definition = object.definition || object.create_definition
    # Update the activity definition attributes excluding extensions
    definition.update(@data[:object][:definition])
    # Create the statement with the associated actor, verb, and object
    statement = XapiMiddleware::Statement.new(actor: actor, verb: verb, object: object)

    raise XapiMiddleware::Errors::XapiError, statement.errors.full_messages.join(", ") unless statement.valid?

    statement.save
    {status: 200, statement: statement}
  end

  private

  # Ensure that an actor inverse functional identifier (IFI) is present.
  #
  # @raise [XapiMiddleware::Errors::XapiError] If the actor is invalid
  def build_actor
    @data[:actor] = @data[:actor].merge(mbox: "mailto:#{@user.email}") if @user[:email].present?
    account_data = @data[:actor][:account]

    if account_data.present?
      account = XapiMiddleware::Account.find_or_create_by(home_page: account_data[:homePage]) do |a|
        a.name = account_data[:name]
      end

      @data[:actor] = @data[:actor].merge(account: account)
      @data[:actor] = @data[:actor].merge(name: account_data[:name]) if @data[:actor][:name].blank?
    end

    conditions = @data[:actor].slice(:mbox, :mbox_sha1sum, :openid).compact
    actor = XapiMiddleware::Actor.where(conditions).first
    actor ||= XapiMiddleware::Actor.create!(@data[:actor])

    raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.actor_ifi_must_be_present") unless actor.valid?

    actor
  end
end
