# frozen_string_literal: true

module Serializable
  extend ActiveSupport::Concern

  LATIN_LETTERS = "a-zA-ZÀ-ÖØ-öø-ÿœ"
  LATIN_LETTERS_REGEX = /[^#{LATIN_LETTERS}\s-]/i

  included do
    def serialized_value(data)
      if data.is_a?(Hash)
        data.to_json
      else
        data.to_s
      end
    end
  end
end
