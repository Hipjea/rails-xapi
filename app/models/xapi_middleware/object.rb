# frozen_string_literal: true

module XapiMiddleware
  class Object < ApplicationRecord
    self.abstract_class = true

    attr_accessor :id, :definition

    def initialize
      @definition = XapiMiddleware::Definition.new
    end

    private

      def initialize_object(object_id:, object_name:)
        obj = XapiMiddleware::Object.new
        obj.id = object_id
        obj.definition.name = object_name
        obj
      end
  end
end
