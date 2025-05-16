# frozen_string_literal: true

# The object optional activity definition.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#activity-definition
class RailsXapi::ActivityDefinition < ApplicationRecord
  include Serializable
  include LanguageMap
  include RailsXapi::ApplicationHelper

  belongs_to :object, class_name: "RailsXapi::Object"
  has_many :extensions, as: :extendable, dependent: :destroy

  before_validation :set_name, :set_description
  validate :language_map_validation

  def type=(value)
    # We store the `type` attribute into `activity_type` column to avoid
    # reserved key-words issues.
    self.activity_type = value
  end

  def moreInfo=(value)
    # We need to match the camel case notation from JSON data.
    self.more_info = value
  end

  def extensions=(extensions_data)
    unless extensions_data.is_a?(Hash)
      raise RailsXapi::Errors::XapiError,
            I18n.t(
              "rails_xapi.errors.attribute_must_be_a_hash",
              name: "extensions"
            )
    end

    # Find any existing extension for the given activity definition.
    exts = extensions.where(extendable_type: self.class.to_s, extendable_id: id)

    # If none, build and save the extensions.
    if exts.blank?
      extensions_data.each do |iri, data|
        extensions.build(iri: iri, value: serialized_value(data))
      end
    end
  end

  def as_json
    { name: name, description: description, type: activity_type }.tap do |hash|
      hash[:extensions] = extensions.as_json if extensions.present?
      hash[:moreInfo] = more_info if more_info.present?
    end
  end

  private

  def set_json_attribute(attribute)
    value = send(attribute)
    return if value.blank?

    begin
      value = JSON.parse(value.to_s.gsub("=>", ":"))
    rescue JSON::ParserError => _
      raise RailsXapi::Errors::XapiError,
            I18n.t(
              "rails_xapi.errors.attribute_must_be_a_valid_language_map",
              name: attribute
            )
    end

    self[attribute] = value.to_json
  end

  def set_name
    set_json_attribute(:name)
  end

  def set_description
    set_json_attribute(:description)
  end
end

# == Schema Information
#
# Table name: rails_xapi_activity_definitions
#
#  id            :integer          not null, primary key
#  activity_type :string
#  description   :text
#  more_info     :text
#  name          :string
#  object_id     :string           not null
#
# Indexes
#
#  index_rails_xapi_activity_definitions_on_object_id  (object_id)
#
