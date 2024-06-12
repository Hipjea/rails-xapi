# frozen_string_literal: true

# Represents a result containing response, success, and score data.
class XapiMiddleware::Result
  require "active_support/core_ext/numeric/time"
  require "uri"

  attr_accessor :response, :success, :score

  # Initializes a new Result instance.
  #
  # @param [Hash] result The result hash containing score, success, completion, response, duration and extensions data.
  # @raise [XapiMiddleware::Errors::XapiError] If the result structure or values are invalid.
  def initialize(result)
    validate_result(result)

    @score = XapiMiddleware::Score.new(raw: result[:score_raw], min: result[:score_min], max: result[:score_max])
    @success = result[:success] || false
    @completion = result[:completion] || false
    @response = result[:response]
    @duration = result[:duration]
    @extensions = result[:extensions]
  end

  # Returns an array of keys present in the result hash.
  #
  # @return [Array<Symbol>] The array of keys.
  delegate :keys, to: :result_hash

  private

  # Output of the result hash.
  #
  # @return [Hash] The result hash to be output.
  def result_hash
    {
      score_raw: @score&.raw,
      score_min: @score&.min,
      score_max: @score&.max,
      response: @response,
      success: @success
    }.compact
  end

  # Validates the overall structure of the result.
  #
  # @param [Hash] result The result hash to validate.
  # @return [XapiMiddleware::Errors::XapiError] If the result structure is invalid.
  def validate_result(result)
    validate_result_structure(result)
    validate_result_values(result)
    validate_duration(result[:duration])
    validate_completion(result[:completion])
    validate_extensions(result[:extensions])
  end

  # Validates the structure of the result hash.
  #
  # @param [Hash] result The result hash to validate.
  # @raise [XapiMiddleware::Errors::XapiError] If the result structure or values are invalid.
  def validate_result_structure(result)
    result_hash = result.is_a?(Hash) ? result : result.as_json
    raise XapiMiddleware::Errors::XapiError, "must be a hash or an object that responds to as_json" unless result_hash.is_a?(Hash)

    required_keys = %i[response success score_raw score_min score_max]
    missing_keys = required_keys - result.keys

    raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.missing_result_keys", keys: missing_keys.join(", ")) if missing_keys.any?
  end

  # Validates the values of the result hash.
  #
  # @param [Hash] result The result hash to validate.
  # @raise [XapiMiddleware::Errors::XapiError] If the result values are missing.
  def validate_result_values(result)
    required_keys = %i[response success score_raw score_min score_max]
    missing_values = required_keys.reject do |key|
      value = result[key]
      value.present? && valid_value_type?(key, value)
    end

    if missing_values.any?
      raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.missing_values_or_invalid_type", values: missing_values.join(", "))
    end
  end

  # Validates the duration accordign to the specifications.
  # See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#46-iso-8601-durations
  #
  # @param [String] duration The duration string to validate.
  # @return [ActiveSupport::Duration::ISO8601Parser::ParsingError] If invalid string is provided.
  def validate_duration(duration)
    ActiveSupport::Duration.parse(duration) if duration.present?
  end

  # Validates the completion value.
  #
  # @param [String|Boolean] duration The duration string or boolean to validate.
  # @return [XapiMiddleware::Errors::XapiError] If invalid completion is provided.
  def validate_completion(completion)
    return if completion.nil?

    valid_string = completion.is_a?(String) && %w[true false].include?(completion)
    valid_boolean = completion.is_a?(TrueClass) || completion.is_a?(FalseClass)

    unless valid_string || valid_boolean
      raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.wrong_attribute_type", name: "completion", value: completion)
    end
  end

  # Validates the extensions accordign to the specifications.
  # See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#41-extensions
  #
  # @param [Object] duration The extensions object to validate.
  # @return [XapiMiddleware::Errors::XapiError] If an invalid object structure is provided.
  def validate_extensions(extensions)
    return if extensions.nil?

    extensions.each do |key, value|
      uri = URI.parse(key.to_s)
      raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.malformed_uri", uri: uri) unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.value_must_not_be_nil", name: key) if value.nil?
    end
  end

  # Checks if the value has the correct type.
  #
  # @param [Symbol] key The key of the value being checked.
  # @param [Object] value The value to check.
  # @return [Boolean] True if the value has the correct type, false otherwise.
  def valid_value_type?(key, value)
    case key
    when :response
      value.is_a?(String)
    when :success
      [true, false].include?(value)
    when :score_raw, :score_min, :score_max
      value.is_a?(Integer)
    else
      true
    end
  end
end
