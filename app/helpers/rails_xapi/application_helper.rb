# frozen_string_literal: true

module RailsXapi
  module ApplicationHelper
    # Output the duration ISO 8601 in minutes.
    def duration_to_minutes(duration)
      sprintf("%.2f", ActiveSupport::Duration.parse(duration)&.in_minutes)
    end
  end
end
