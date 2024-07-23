# frozen_string_literal: true

# Represents an account with home_page and name.
class XapiMiddleware::Account < ApplicationRecord
  require "uri"

  belongs_to :actor, class_name: "XapiMiddleware::Actor", dependent: :destroy

  def homePage=(value)
    # We need to match the camel case notation from JSON data.
    self.home_page = value
  end
end

# == Schema Information
#
# Table name: xapi_middleware_accounts
#
#  id        :integer          not null, primary key
#  home_page :string           not null
#  name      :string           not null
#
