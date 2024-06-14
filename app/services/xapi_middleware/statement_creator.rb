# frozen_string_literal: true

class XapiMiddleware::StatementCreator < ApplicationService
  attr_reader :user, :data

  def initialize(data)
    @data = data
  end

  def call
    statement = XapiMiddleware::Statement.new(statement_json: @data.to_json)
    unless statement.valid?
      return {error: statement.errors.full_messages.join(", ")}
    end

    statement
  rescue XapiMiddleware::Errors::XapiError => e
    Rails.logger.error("Error in StatementService: #{e.message}")
    {error: "An unexpected error occurred."}
  end
end
