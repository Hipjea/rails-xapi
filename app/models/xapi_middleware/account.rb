# frozen_string_literal: true

# Represents an account with home_page and name.
class XapiMiddleware::Account < ApplicationRecord
  require "uri"

  has_many :actors, class_name: "XapiMiddleware::Actor", dependent: :nullify

  def homePage=(value)
    self.home_page = value
  end

  private
end

# == Schema Information
#
# Table name: xapi_middleware_accounts
#
#  id        :integer          not null, primary key
#  home_page :string           not null
#  name      :string           not null
#
