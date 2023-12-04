# frozen_string_literal: true

module XapiMiddleware
  class Statement
    attr_accessor :object, :actor, :verb_uri, :result

    def initialize(verb_uri: "", object:, actor:, result: nil)
      @actor = XapiMiddleware::Actor.new(actor)
      @verb_uri = verb_uri
      @object = XapiMiddleware::Object.new(object)
      @result = XapiMiddleware::Result.new(result) if result.present?
    end

    def output
      log_output if XapiMiddleware.configuration.output_xapi_logs
      self
    end

    private

    def pretty_print
      JSON.pretty_generate(as_json)
    end

    def log_output
      Rails.logger.info Rainbow("#{I18n.t("xapi_middleware.xapi_statement")} => #{pretty_print}").yellow
    end
  end
end
