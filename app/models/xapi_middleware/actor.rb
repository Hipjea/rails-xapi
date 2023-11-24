# frozen_string_literal: true

module XapiMiddleware
  class Actor
    attr_accessor :name, :mbox

    def initialize(name:, mbox:)
      @name = name
      @mbox = mbox
    end
  end
end
