# frozen_string_literal: true

module XapiMiddleware
  class Definition < ApplicationRecord
    self.abstract_class = true

    attr_accessor :name

    def initialize
      @name = {}
    end
  end
end
