# frozen_string_literal: true

module XapiMiddleware
  class Definition
    attr_accessor :name

    def initialize(name:)
      @name = name
    end
  end
end
