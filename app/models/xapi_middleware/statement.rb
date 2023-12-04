# frozen_string_literal: true

module XapiMiddleware
  class Statement < ApplicationRecord
    attr_accessor :object, :actor, :result

    after_initialize :set_data

    def set_data
      @actor = XapiMiddleware::Actor.new(actor)
      @object = XapiMiddleware::Object.new(object)
      @result = XapiMiddleware::Result.new(result) if result.present?
      self.object_identifier = @object.id
      self.statement_json = as_json
    end

    def output
      log_output if XapiMiddleware.configuration.output_xapi_logs
      self
    end

    private

      def as_json
        {
          verb_id: verb_id,
          object: @object&.as_json,
          actor: @actor&.as_json,
          result: @result&.as_json
        }
      end

      def pretty_print
        JSON.pretty_generate(as_json)
      end

      def log_output
        Rails.logger.info Rainbow("#{I18n.t("xapi_middleware.xapi_statement")} => #{statement_json}").yellow
      end
  end
end
