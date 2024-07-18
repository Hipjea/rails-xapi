# frozen_string_literal: true

# The object optional activity definition.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#activity-definition
class XapiMiddleware::ActivityDefinition < ApplicationRecord
  include Serializable

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
      extension.value = serialized_value(data)
      extensions << extension
    end
  end
end
