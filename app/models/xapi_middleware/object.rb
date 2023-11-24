# frozen_string_literal: true

module XapiMiddleware
  class Object
    attr_accessor :id, :definition

    def initialize(id:, name:)
      @id = id
      @definition = XapiMiddleware::Definition.new(name: name)
    end
  end
end
