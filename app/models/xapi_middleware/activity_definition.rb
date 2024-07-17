# frozen_string_literal: true

# The object optional activity definition.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#activity-definition
class XapiMiddleware::ActivityDefinition < ApplicationRecord
  belongs_to :object, class_name: "XapiMiddleware::Object"
  has_many :extensions, class_name: "XapiMiddleware::Extension", foreign_key: "definition_id", dependent: :destroy

  def extensions=(extensions_data)
    extensions_data.each do |iri, data|
      extension = find_or_initialize_extension(iri)
      extension.value = serialize_value(data)
      # Check if extension with iri already exists
      extensions << extension unless extensions.exists?(iri: iri)
    end
  end

  private

  def find_or_initialize_extension(iri)
    extensions.find_by(iri: iri) || extensions.build(iri: iri)
  end

  def serialize_value(data)
    if data.is_a?(Hash)
      data.to_json
    else
      data.to_s
    end
  end
end
