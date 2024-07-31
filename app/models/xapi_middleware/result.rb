# frozen_string_literal: true

# Represents a result containing response, success, and score data.
class XapiMiddleware::Result < ApplicationRecord
  require "active_support/duration"
  require "uri"
  include Serializable

  belongs_to :statement, class_name: "XapiMiddleware::Statement", dependent: :destroy
  has_many :extensions, as: :extendable, dependent: :destroy

  attr_reader :duration_in_seconds

  validates :score_scaled, numericality: {greater_than_or_equal_to: -1, less_than_or_equal_to: 1}, allow_nil: true
  validate :completion_attribute_must_be_boolean, if: -> { completion.present? }
  validate :success_attribute_must_be_boolean, if: -> { success.present? }
  validate :correct_duration, if: -> { duration.present? }

  before_validation :calculate_scaled

  # Store the score object in the results table for convenience reasons.
  #
  # @param [Hash] value The result hash values.
  def score=(value)
    validate_score(value)

    self.score_scaled = value[:scaled]
    self.score_raw = value[:raw]
    self.score_min = value[:min]
    self.score_max = value[:max]
  end

  # Transform a duration in seconds into a ISO 8601 string.
  # This is an optional attribute meant to bring more convenience for some systems.
  #
  # @param [String|Number] value The duration in seconds.
  def duration_in_seconds=(value)
    self.duration = ActiveSupport::Duration.build(value).iso8601 if value.present?
  end

  def extensions=(extensions_data)
    extensions_data.each do |iri, data|
      extension = extensions.build(iri: iri)
      extension.value = serialized_value(data)
      extensions << extension
    end
  end

  private

  # Validations in regard to the score
  # See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#2451-score
  #
  # @param [Hash] value The result's score hash values.
  def validate_score(value)
    if value[:scaled].present? && !value[:scaled]&.between?(-1, 1)
      raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.invalid_score_value",
        value: I18n.t("xapi_middleware.validations.score.scaled"))
    end

    min_value = value[:min].to_i if value[:min].present?
    max_value = value[:max].to_i if value[:max].present?

    if value[:raw].present? && !value[:raw]&.between?(min_value || -Float::INFINITY, max_value || Float::INFINITY)
      raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.invalid_score_value",
        value: I18n.t("xapi_middleware.validations.score.raw"))
    end

    if max_value.present? && min_value && min_value >= max_value
      raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.invalid_score_value",
        value: I18n.t("xapi_middleware.validations.score.min"))
    end

    if min_value.present? && max_value && max_value <= min_value
      raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.invalid_score_value",
        value: I18n.t("xapi_middleware.validations.score.max"))
    end
  end

  # Validates the duration accordign to the specifications.
  # See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#46-iso-8601-durations
  #
  # @param [String] duration The duration string to validate.
  # @return [ActiveSupport::Duration::ISO8601Parser::ParsingError] If invalid string is provided.
  def correct_duration
    ActiveSupport::Duration.parse(duration) if duration.present?
  end

  def completion_attribute_must_be_boolean
    unless [true, false].include?(completion)
      raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.invalid_score_value",
        value: I18n.t("xapi_middleware.errors.wrong_attribute_type", name: "completion", value: completion))
    end
  end

  def success_attribute_must_be_boolean
    unless [true, false].include?(success)
      raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.invalid_score_value",
        value: I18n.t("xapi_middleware.errors.wrong_attribute_type", name: "success", value: success))
    end
  end

  # Automatically set a score_scaled if not provided.
  def calculate_scaled
    return if score_scaled.present? || score_max.blank? || score_raw.blank?

    self.score_scaled = (score_raw.to_f / score_max.to_f)
  end
end

# == Schema Information
#
# Table name: xapi_middleware_results
#
#  id           :integer          not null, primary key
#  completion   :boolean          default(FALSE)
#  duration     :string
#  response     :text
#  score_max    :integer
#  score_min    :integer
#  score_raw    :integer
#  score_scaled :decimal(3, 2)
#  success      :boolean          default(FALSE)
#  statement_id :bigint           not null
#
# Indexes
#
#  index_xapi_middleware_results_on_statement_id  (statement_id)
#
