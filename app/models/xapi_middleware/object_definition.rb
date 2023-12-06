# frozen_string_literal: true

module XapiMiddleware
  class ObjectDefinition
    attr_accessor :name

    # Initializes a new ObjectDefinition instance.
    #
    # @param [String] name The name of the object definition.
    def initialize(definition)
      @name = definition[:name].presence
    end

    # Overrides the Hash class method.
    #
    # @return [Hash] The object definition hash.
    def to_hash
      {name: @name}.compact
    end
  end
end
