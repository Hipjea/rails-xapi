# frozen_string_literal: true

module XapiMiddleware
  class ObjectDefinition
    attr_accessor :name

    # Initializes a new ObjectDefinition instance.
    #
    # @param [Hash] definition The object definition hash.
    def initialize(definition)
      @name = {}
      @description = {}

      add_values_to_key(definition[:name], @name)
      add_values_to_key(definition[:description], @description)
    end

    # Adds values to the corresponding key, to allow multiple languages values.
    #
    # @param [Hash] attr The hash attribute that contains the values.
    # @param [Hash] key The hash attribute to be defined.
    def add_values_to_key(attr, key)
      if attr.is_a?(Hash) && attr.any?
        attr.each do |k, v|
          key[k.to_sym] = v
        end
      end
    end

    # Overrides the Hash class method.
    #
    # @return [Hash] The object definition hash.
    def to_hash
      {
        name: @name,
        description: @description
      }.compact
    end
  end
end
