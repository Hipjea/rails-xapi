# frozen_string_literal: true

module LanguageMap
  extend ActiveSupport::Concern

  LANGUAGE_MAP_REGEX = /\A[a-z]{2}(-[A-Z]{2})?\z/

  def language_map_validation
    if defined?(display) && display.present?
      validate_language_map(display)
    end

    if defined?(description) && description.present?
      validate_language_map(description)
    end
  end

  private

  def is_valid_json?(content)
    !!JSON.parse(content)
  end

  def validate_language_map(data)
    raise RailsXapi::Errors::XapiError, I18n.t("rails_xapi.errors.invalid_json") if !is_valid_json?(data)

    data_hash = JSON.parse(data)

    # Validate language map keys to match keys that are either:
    # - A 2-letter lowercase language code (e.g.: "en")
    # - A 2-letter lowercase language code followed by a hyphen and a 2-letter uppercase region code (e.g.: "en-US")
    invalid_keys = data_hash.keys.reject { |key| key.match?(LANGUAGE_MAP_REGEX) }

    if invalid_keys.any?
      raise RailsXapi::Errors::XapiError,
        I18n.t("rails_xapi.errors.definition_description_invalid_keys", values: invalid_keys.join(", "))
    end
  end
end
