# frozen_string_literal: true

module XapiMiddleware
  # Representation class of an error raised by the Statement class.
  class StatementError < StandardError; end

  class Statement < ApplicationRecord
    attr_accessor :object, :actor, :result

    LATIN_LETTERS = "a-zA-ZÀ-ÖØ-öø-ÿœ"
    LATIN_LETTERS_REGEX = /[^#{LATIN_LETTERS}\s-]/i

    after_initialize :set_data

    validates :verb_id, presence: true
    validate :validate_verb_id_format
    validates :object_identifier, presence: true
    validates :actor_name, presence: true
    validates :statement_json, presence: true

    normalizes :actor_name, with: ->(actor_name) {
      actor_name.gsub(LATIN_LETTERS_REGEX, "")
        .to_s
        .humanize
        .gsub(/\b('?[#{LATIN_LETTERS}])/) { Regexp.last_match(1).capitalize }
    }

    # Sets the data to construct the xAPI statement to be stored in the database.
    # The full statement is represented in JSON in statement_json.
    def set_data
      @verb = XapiMiddleware::Verb.new(verb_id)
      @actor = XapiMiddleware::Actor.new(actor)
      @object = XapiMiddleware::Object.new(object)
      @result = XapiMiddleware::Result.new(result) if result.present?
      self.object_identifier = @object.id
      self.actor_name = @actor.name
      self.statement_json = prepare_json
    end

    # Outputs the xAPI statement in the logs.
    #
    # @return [Statement]
    def output
      log_output if XapiMiddleware.configuration.output_xapi_logs
      self
    end

    private

      # Validates the verb_id URL.
      #
      # @return [StatementError] If the verb_id value is invalid.
      def validate_verb_id_format
        return if verb_id.blank?

        uri = URI.parse(verb_id)
        is_valid = uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

        unless verb_id.present? && is_valid
          raise StatementError, I18n.t("xapi_middleware.errors.invalid_verb_id_url")
        end
      end

      # Output of the statement as JSON.
      #
      # @return [String] The JSON representation of the statement.
      def prepare_json
        {
          verb: @verb,
          object: @object,
          actor: @actor.to_hash,
          result: @result
        }.to_json
      end

      # Outputs the xAPI statement in the logs.
      def log_output
        Rails.logger.info { "#{I18n.t("xapi_middleware.xapi_statement")} => #{JSON.pretty_generate(as_json)}" }
      end
  end
end

# == Schema Information
#
# Table name: xapi_middleware_statements
#
#  id                :integer          not null, primary key
#  actor_name        :string
#  object_identifier :string
#  statement_json    :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  verb_id           :string
#
