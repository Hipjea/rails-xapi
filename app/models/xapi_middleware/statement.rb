# frozen_string_literal: true

module XapiMiddleware
  # Representation class of an error raised by the Statement class.
  class StatementError < StandardError; end

  class Statement < ApplicationRecord
    # Statements are the evidence for any sort of experience or event which is to be tracked in xAPI.
    # See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#20-statements

    # The Object of a Statement can be an Activity, Agent/Group, SubStatement, or Statement Reference.
    OBJECT_TYPES = ["Activity", "Agent", "Group", "SubStatement", "StatementRef"].freeze
    LATIN_LETTERS = "a-zA-ZÀ-ÖØ-öø-ÿœ"
    LATIN_LETTERS_REGEX = /[^#{LATIN_LETTERS}\s-]/i

    attr_accessor :object, :actor, :result, :verb, :substatement

    validates :verb_id, :verb_display, :object_type, :actor_name, :statement_json, presence: true
    validates :object_identifier, presence: true, unless: -> { object_type == OBJECT_TYPES[3] }
    validate :validate_verb_id_format

    normalizes :actor_name, with: ->(actor_name) {
      actor_name.gsub(LATIN_LETTERS_REGEX, "")
        .to_s
        .humanize
        .gsub(/\b('?[#{LATIN_LETTERS}])/) { Regexp.last_match(1).capitalize }
    }

    after_initialize :set_data
    before_save :create_substatement, if: -> { object_type == OBJECT_TYPES[3] }

    # Sets the data to construct the xAPI statement to be stored in the database.
    # The full statement is represented in JSON in statement_json.
    def set_data
      @verb = XapiMiddleware::Verb.new(verb)
      @actor = XapiMiddleware::Actor.new(actor)
      @object = XapiMiddleware::Object.new(object)
      @result = XapiMiddleware::Result.new(result) if result.present?

      self.verb_id = @verb.id
      self.verb_display = @verb.generic_display
      self.verb_display_full = @verb.display.to_json
      self.object_type = @object.object_type
      self.object_identifier = @object.id&.presence
      self.actor_name = @actor.name
      self.statement_json = prepare_json
    end

    # Prepares a new substatement row.
    #
    # @param [XapiMiddleware::Object] object The substatement object.
    def prepare_substatement(object)
      sub = self.class.new(
        object_type: OBJECT_TYPES[4],
        actor: object.actor,
        verb: object.verb,
        object: object.object
      )

      return sub if sub.valid?

      error_msg = I18n.t("xapi_middleware.errors.couldnt_create_the_substatement")
      Rails.logger.error("#{error_msg} : #{err}")
      raise StatementError, error_msg
    end

    # Creates a substatement if the objectType is SubStatement.
    def create_substatement
      self.substatement = prepare_substatement(@object)
      self.object_type = OBJECT_TYPES[3]
      # Save the substatement
      substatement.save
      # Set the main statement object_identifier to the substatement id
      self.object_identifier = substatement.id
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
          verb: @verb.to_hash,
          object: @object.to_hash,
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
#  id                     :integer          not null, primary key
#  actor_account_homepage :string
#  actor_account_name     :string
#  actor_mbox             :string
#  actor_name             :string
#  actor_openid           :string
#  actor_sha1sum          :string
#  object_identifier      :string
#  object_type            :string
#  statement_json         :text
#  verb_display           :string
#  verb_display_full      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  verb_id                :string
#
