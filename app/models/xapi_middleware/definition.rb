# frozen_string_literal: true

module XapiMiddleware
  class Definition
    attr_accessor :name

    # Initializes a new Definition instance.
    #
    # @param [String] name The name of the definition.
    def initialize(name:)
      @name = name
    end
  end
end
