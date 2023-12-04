# frozen_string_literal: true

module XapiMiddleware
  class Actor
    attr_accessor :name, :mbox

    def initialize(actor)
      @name = actor[:name]
      @mbox = XapiMiddleware::Mbox.new(actor[:mbox])
    end
  end
end
