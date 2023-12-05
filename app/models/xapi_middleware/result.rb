# frozen_string_literal: true

module XapiMiddleware
  class ResultError < StandardError; end

  class Result
    attr_accessor :response, :success, :score

    # Initializes a new Result instance.
    #
    # @param result [Hash] The result hash containing response, success, and score data.
    # @raise [ResultError] If the result structure or values are invalid.
    def initialize(result)
      validate_result(result)

      @response = result[:response]
      @success = result[:success] || false
      @score = Score.new(raw: result[:score_raw], min: result[:score_min], max: result[:score_max])
    end

    # Returns an array of keys present in the result hash.
    #
    # @return [Array<Symbol>] The array of keys.
    def keys
      result_hash.keys
    end

    private

      # Output of the result hash.
      #
      # @return [Hash] The result hash to be output.
      def result_hash
        {
          response: @response,
          success: @success,
          score_raw: @score&.raw,
          score_min: @score&.min,
          score_max: @score&.max
        }
      end

      def validate_result(result)
        validate_result_structure(result)
        validate_result_values(result)
      end

      # Validates the structure of the result hash.
      #
      # @param [Hash] result The result hash to validate.
      # @raise [ResultError] If the result structure or values are invalid.
      def validate_result_structure(result)
        result_hash = result.is_a?(Hash) ? result : result.as_json
        raise ResultError, "must be a hash or an object that responds to as_json" unless result_hash.is_a?(Hash)
    
        required_keys = %i[response success score_raw score_min score_max]
        missing_keys = required_keys - result.keys

        raise ResultError, "missing keys: #{missing_keys.join(', ')}" unless missing_keys.empty?
      end

      # Validates the values of the result hash.
      #
      # @param [Hash] result The result hash to validate.
      # @raise [ResultError] If the result values are missing.
      def validate_result_values(result)
        required_keys = %i[response success score_raw score_min score_max]
        missing_values = required_keys.reject { |key| result[key].present? }

        raise ResultError, "missing values #{missing_values.join(', ')}" unless missing_values.empty?
      end
  end

  class Score
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
end
