# frozen_string_literal: true

# The object optional activity definition's extensions.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#41-extensions
class RailsXapi::Extension < ApplicationRecord
  belongs_to :extendable, polymorphic: true

  after_initialize :validate_data

  def validate_data
    unless attributes.is_a?(Hash)
      raise RailsXapi::Errors::XapiError, I18n.t("rails_xapi.errors.attribute_must_be_a_hash", name: "extensions")
    end
  end
end

# == Schema Information
#
# Table name: rails_xapi_extensions
#
#  id              :integer          not null, primary key
#  extendable_type :string
#  iri             :string           not null
#  value           :text             not null
#  extendable_id   :integer
#
# Indexes
#
#  index_rails_xapi_extensions_on_extendable  (extendable_type,extendable_id)
#
