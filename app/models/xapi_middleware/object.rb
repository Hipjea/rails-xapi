# frozen_string_literal: true

module XapiMiddleware
  class Object
    attr_accessor :id, :definition

    def initialize(object)
      @id = object[:id]
      @definition = XapiMiddleware::Definition.new(name: object[:name])
    end
  end
end
