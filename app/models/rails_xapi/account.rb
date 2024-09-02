# frozen_string_literal: true

# Represents an account with home_page and name.
class RailsXapi::Account < ApplicationRecord
  require "uri"

  belongs_to :actor, class_name: "RailsXapi::Actor", dependent: :destroy

  def homePage=(value)
    # We need to match the camel case notation from JSON data.
    self.home_page = value
  end
end

# == Schema Information
#
# Table name: rails_xapi_accounts
#
#  id        :integer          not null, primary key
#  home_page :string           not null
#  name      :string           not null
#  actor_id  :bigint           not null
#
# Indexes
#
#  index_rails_xapi_accounts_on_actor_id  (actor_id)
#
