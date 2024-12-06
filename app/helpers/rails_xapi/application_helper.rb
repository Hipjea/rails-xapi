# frozen_string_literal: true

module RailsXapi
  module ApplicationHelper
    # Output the duration ISO 8601 in minutes.
    def duration_to_minutes(duration)
      sprintf("%.2f", ActiveSupport::Duration.parse(duration)&.in_minutes)
    end

    # Output the value of a JSON row in a specific locale.
    def json_value_for_locale(json_str, locale = I18n.locale)
      hash = JSON.parse(json_str)
      result = hash.select { |key, _value| key.include?(locale.to_s) }
      result.values.first.to_s || hash.first.value.to_s
    rescue
      json_str
    end

    # Output the result score as a percentage.
    def result_success_rate(result)
      return nil if result.score_raw.blank? || result.score_max.blank?

      raw = result.score_raw.to_f
      max = result.score_max.to_f

      (raw / max * 100).to_i
    end
  end
end
