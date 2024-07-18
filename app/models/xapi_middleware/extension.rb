# frozen_string_literal: true

# The object optional activity definition's extensions.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#41-extensions
class XapiMiddleware::Extension < ApplicationRecord
  belongs_to :extendable, polymorphic: true

  def data=(attributes)
    if attributes.is_a?(Hash) && attributes.keys.length == 1
      self.iri = attributes.keys.first.to_s
      self.value = attributes.values.first.to_s
    else
      raise ArgumentError, "Invalid data format for Extension"
    end
  end
end
