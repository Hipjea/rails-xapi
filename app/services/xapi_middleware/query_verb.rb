# frozen_string_literal: true

# This class manages the query interface for verbs.
class XapiMiddleware::QueryVerb < ApplicationService
  # Get a list of all unique verb_id values
  #
  # @return [ActiveRecord::Relation] The unique verb_id values
  def self.verb_ids
    XapiMiddleware::Statement.distinct.pluck(:verb_id)
  end

  # Get a list of all unique verb_display values
  #
  # @return [ActiveRecord::Relation] The unique verb_display values
  def self.verb_displays
    XapiMiddleware::Statement.distinct.pluck(:verb_display)
  end

  # Get a hash of all unique verbs with verb_id as keys and verb_display as values.
  #
  # @return [Hash] A hash where keys are verb_id and values are verb_display.
  def self.verbs
    XapiMiddleware::Statement.distinct.pluck(:verb_id, :verb_display).to_h
  end
end
