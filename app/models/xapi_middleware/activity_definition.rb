# frozen_string_literal: true

# The object optional activity definition.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#activity-definition
class XapiMiddleware::ActivityDefinition < ApplicationRecord
  belongs_to :object, class_name: "XapiMiddleware::Object"
  has_many :extensions, as: :extendable, dependent: :destroy

  def type=(value)
    self.activity_type = value
  end

  def moreInfo=(value)
    self.more_info = value
  end

  def extensions=(extensions_data)
    extensions_data.each do |iri, data|
      extension = extensions.build(iri: iri)
      extension.value = serialize_value(data)
      extensions << extension
    end
  end

  private

  def serialize_value(data)
    if data.is_a?(Hash)
      data.to_json
    else
      data.to_s
    end
  end
end
