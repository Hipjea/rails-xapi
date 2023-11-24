# frozen_string_literal: true

module XapiMiddleware
  class Statement
    attr_accessor :object, :actor

    def initialize(verb_uri:, object_id: nil, object_name: nil, actor_name: nil, actor_mbox: nil)
      @verb_uri = verb_uri
      @object = XapiMiddleware::Object.new(id: object_id, name: object_name)
      @actor = XapiMiddleware::Actor.new(name: actor_name, mbox: actor_mbox)
    end

    def output
      log_output if XapiMiddleware.configuration.output_xapi_logs
      self
    end

    private

      def pretty_print
        JSON.pretty_generate(self.as_json)
      end

      def log_output
        Rails.logger.info Rainbow("#{I18n.t("xapi_middleware.xapi_statement")} => #{self.pretty_print}").yellow
      end
  end
end
