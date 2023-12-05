# frozen_string_literal: true

module XapiMiddleware
  class Object
    attr_accessor :id, :definition

    # Initializes a new Object instance.
    #
    # @param [Hash] object The object hash containing id and name.
    def initialize(object)
      @id = object[:id]
      @definition = XapiMiddleware::Definition.new(name: object[:name])
    end
  end
end
