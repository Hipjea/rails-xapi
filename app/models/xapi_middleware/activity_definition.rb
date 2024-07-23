# frozen_string_literal: true

# The object optional activity definition.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#activity-definition
class XapiMiddleware::ActivityDefinition < ApplicationRecord
  include Serializable

  belongs_to :object, class_name: "XapiMiddleware::Object"
  has_many :extensions, as: :extendable, dependent: :destroy

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
    extensions_data.each do |iri, data|
      extension = extensions.build(iri: iri)
      extension.value = serialized_value(data)
      extensions << extension
    end
  end
end

# == Schema Information
#
# Table name: xapi_middleware_activity_definitions
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
#  index_xapi_middleware_activity_definitions_on_object_id  (object_id)
#
