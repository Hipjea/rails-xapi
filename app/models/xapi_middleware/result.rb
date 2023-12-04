# frozen_string_literal: true

module XapiMiddleware
  class Result
    attr_accessor :response, :success, :score

    def initialize(result)
      @response = result[:response]
      @success = result[:success] || false
      @score = Score.new(raw: result[:score_raw], min: result[:score_min], max: result[:score_max])
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
