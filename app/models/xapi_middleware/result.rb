# frozen_string_literal: true

# Represents a result containing response, success, and score data.
class XapiMiddleware::Result < ApplicationRecord
  require "active_support/duration"
  require "uri"
  include Serializable

  belongs_to :statement, class_name: "XapiMiddleware::Statement", dependent: :destroy
  has_many :extensions, as: :extendable, dependent: :destroy

  validates :success, inclusion: {in: [true, false]}
  validates :completion, inclusion: {in: [true, false]}
  validates :score_scaled, numericality: {greater_than_or_equal_to: -1, less_than_or_equal_to: 1}, allow_nil: true

  def score=(value)
    self.score_scaled = value[:scaled]
    self.score_raw = value[:raw]
    self.score_min = value[:min]
    self.score_max = value[:max]
  end

  def extensions=(extensions_data)
    extensions_data.each do |iri, data|
      extension = extensions.build(iri: iri)
      extension.value = serialized_value(data)
      extensions << extension
    end
  end

  private

  def set_duration(time_in_seconds)
    return nil if time_in_seconds.blank?

    ActiveSupport::Duration.build(time_in_seconds).iso8601
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
