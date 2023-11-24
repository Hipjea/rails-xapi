# frozen_string_literal: true

module XapiMiddleware
  class Actor < ApplicationRecord
    self.abstract_class = true

    attr_accessor :name, :mbox
  end
end
