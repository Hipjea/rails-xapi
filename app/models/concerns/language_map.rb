# frozen_string_literal: true

module LanguageMap
  extend ActiveSupport::Concern

  def language_map_validation
    if defined?(display) && display.present?
      validate_language_map(display)
    end

    if defined?(description) && description.present?
      validate_language_map(description)
    end
  end

  private

  def validate_language_map(data)
    data_hash = JSON.parse(data)

    # Validate language map keys to match keys that are either:
    # - A 2-letter lowercase language code (e.g.: "en")
    # - A 2-letter lowercase language code followed by a hyphen and a 2-letter uppercase region code (e.g.: "en-US")
    language_map_regex = /\A[a-z]{2}(-[A-Z]{2})?\z/
    invalid_keys = data_hash.keys.reject { |key| key.match?(language_map_regex) }

    if invalid_keys.any?
      raise XapiMiddleware::Errors::XapiError,
        I18n.t("xapi_middleware.errors.definition_description_invalid_keys", values: invalid_keys.join(", "))
    end
  end
end
