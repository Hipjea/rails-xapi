# frozen_string_literal: true

class XapiMiddleware::CreateStatementJob < ApplicationJob
  queue_as :default

  def perform(statement)
    statement.save if statement.present?
  end
end
