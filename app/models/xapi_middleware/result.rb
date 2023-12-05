# frozen_string_literal: true

module XapiMiddleware
  class Result
    attr_accessor :response, :success, :score

    def initialize(result)
      validate_result_structure(result)

      @response = result[:response]
      @success = result[:success] || false
      @score = Score.new(raw: result[:score_raw], min: result[:score_min], max: result[:score_max])
    end

    def keys
      result_hash.keys
    end

    private

      def result_hash
        {
          response: @response,
          success: @success,
          score_raw: @score&.raw,
          score_min: @score&.min,
          score_max: @score&.max
        }
      end

      def validate_result_structure(result)
        result_hash = result.is_a?(Hash) ? result : result.as_json
        raise Exception.new("must be a hash or an object that responds to as_json") unless result_hash.is_a?(Hash)
    
        required_keys = %i[response success score_raw score_min score_max]
        missing_keys = required_keys - result.keys

        raise Exception.new("missing keys: #{missing_keys.join(', ')}") unless missing_keys.empty?
      end
  end

  class Score
    attr_accessor :raw, :min, :max

    def initialize(raw:, min:, max:)
      @raw = raw
      @min = min
      @max = max
    end
  end
end
