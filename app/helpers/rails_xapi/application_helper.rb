# frozen_string_literal: true

module RailsXapi
  module ApplicationHelper
    # Output the duration ISO 8601 in minutes.
    def duration_to_minutes(duration)
      sprintf("%.2f", ActiveSupport::Duration.parse(duration)&.in_minutes)
    end

    # Output the value of a JSON row in a specific locale.
    def json_value_for_locale(json, locale = I18n.locale)
      hash = JSON.parse(json)
      result = hash.select { |key, _value| key.include?(locale.to_s) }
      result.values.first.to_s || hash.first.value.to_s
    end
  end
end
