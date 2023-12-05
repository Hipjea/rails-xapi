# frozen_string_literal: true

module XapiMiddleware
  class Actor
    attr_accessor :name, :mbox

    # Initializes a new Actor instance.
    #
    # @param [String] name The name of the actor.
    # @param [String] mbox The mbox of the actor.
    def initialize(actor)
      @name = actor[:name]
      @mbox = actor[:mbox]
    end
  end
end
