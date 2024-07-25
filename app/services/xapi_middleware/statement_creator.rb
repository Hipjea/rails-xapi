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
    actor = XapiMiddleware::Actor.build_from_data(@data[:actor], @user & [:email])

    verb = XapiMiddleware::Verb.find_or_create_by(id: @data[:verb][:id]) do |v|
      v.display = @data[:verb][:display]
    end

    object = XapiMiddleware::Object.find_or_create(@data[:object])
    object.update_definition(@data[:object][:definition])

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
end
