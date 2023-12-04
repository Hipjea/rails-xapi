# frozen_string_literal: true

module XapiMiddleware
  class Mbox
    attr_accessor :email

    def initialize(email)
      @email = email
    end

    def as_json
      { mbox: email }
    end
  end
end
