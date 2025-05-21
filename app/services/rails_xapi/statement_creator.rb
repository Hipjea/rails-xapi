# frozen_string_literal: true

class RailsXapi::StatementCreator < ApplicationService
  def initialize(data, actor = {}, opts = {})
    @data = data
    @actor = actor
    @opts = opts
  end

  def self.create(data, actor = {}, opts = {})
    s = RailsXapi::StatementCreator.new(data, actor, opts).prepare_statement
    # Use a job for asynchronous calls
    return RailsXapi::CreateStatementJob.perform_now(s) if opts[:async]

    s.save
    { status: 200, statement: s }
  end

  def prepare_statement
    actor =
      RailsXapi::Actor.build_actor_from_data(@actor.presence || @data[:actor])

    verb =
      RailsXapi::Verb.find_or_create_by(id: @data[:verb][:id]) do |v|
        v.display = @data[:verb][:display]
      end

    object = RailsXapi::Object.find_or_create(@data[:object])
    object.update_definition(@data[:object][:definition])

    result = RailsXapi::Result.new(@data[:result]) if @data[:result].present?
    context = RailsXapi::Context.new(@data[:context]) if @data[
      :context
    ].present?

    # Create the statement with the associated properties
    statement =
      RailsXapi::Statement.new(
        actor: actor,
        verb: verb,
        object: object,
        result: result,
        context: context,
        timestamp: @data[:timestamp].presence || Time.zone.now
      )
    unless statement.valid?
      raise RailsXapi::Errors::XapiError,
            statement.errors.full_messages.join(", ")
    end

    statement
  end
end
