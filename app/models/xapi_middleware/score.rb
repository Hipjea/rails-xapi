# frozen_string_literal: true

class XapiMiddleware::Score
  # This class represents a score with raw, min, and max values.

  attr_accessor :raw, :min, :max

  # Initializes a new Score instance.
  #
  # @param raw [Integer] The raw score value.
  # @param min [Integer] The minimum score value.
  # @param max [Integer] The maximum score value.
  def initialize(raw:, min:, max:)
    @raw = raw
    @min = min
    @max = max
  end
end
