# frozen_string_literal: true

# The object optional activity definition's extensions.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#41-extensions
class XapiMiddleware::Extension < ApplicationRecord
  belongs_to :definition, class_name: "XapiMiddleware::ActivityDefinition", optional: true
  # belongs_to :result, class_name: "XapiMiddleware::ActivityDefinition", optional: true

  # validate :at_least_one_foreign_key_present

  def data=(attributes)
    if attributes.is_a?(Hash) && attributes.keys.length == 1
      self.iri = attributes.keys.first.to_s
      self.value = attributes.values.first.to_s
    else
      raise ArgumentError, "Invalid data format for Extension"
    end
  end

  # private

  # def at_least_one_foreign_key_present
  #   if definition_id.blank? && result_id.blank?
  #     errors.add(:base, "definition_id or result_id must be present")
  #   end
  # end
end
