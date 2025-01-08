# frozen_string_literal: true

class RailsXapi::CreateStatementJob < ApplicationJob
  queue_as :default

  def perform(statement)
    statement.save if statement.present?

    {status: 200, statement: statement}
  end
end
