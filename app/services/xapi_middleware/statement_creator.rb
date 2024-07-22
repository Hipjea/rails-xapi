# frozen_string_literal: true

class XapiMiddleware::StatementCreator < ApplicationService
  attr_reader :data, :user

  def initialize(data, user = {})
    @data = data
    @user = user
  end

  def call
    statement = prepare_statement
    statement.save

    {status: 200, statement: statement}
  end

  def call_async
    statement = prepare_statement
    XapiMiddleware::CreateStatementJob.perform_now(statement)
  end

  private

  def prepare_statement
    actor = build_actor
    verb = build_verb
    object = build_object

    result = XapiMiddleware::Result.new(@data[:result]) if @data[:result].present?
    context = XapiMiddleware::Context.new(@data[:context]) if @data[:context].present?

    # Create the statement with the associated properties
    statement = XapiMiddleware::Statement.new(
      actor: actor,
      verb: verb,
      object: object,
      result: result,
      context: context,
      timestamp: @data[:timestamp]
    )
    raise XapiMiddleware::Errors::XapiError, statement.errors.full_messages.join(", ") unless statement.valid?

    statement
  end

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

  def build_verb
    XapiMiddleware::Verb.find_or_create_by(id: @data[:verb][:id]) do |v|
      v.display = @data[:verb][:display]
    end
  end

  def build_object
    object = XapiMiddleware::Object.find_or_initialize_by(id: @data[:object][:id])
    object.object_type = @data[:object][:objectType].presence || "Activity"

    if object.new_record?
      if object.object_type == "SubStatement"
        object.actor = @data[:object][:actor]
        object.verb = @data[:object][:verb]
        object.object = @data[:object][:object]
      end
    else
      object.update(object_type: @data[:object][:objectType])
    end

    if @data[:object][:definition].present?
      definition = object.definition || object.create_definition
      definition.update(@data[:object][:definition])
    end

    object
  end
end
