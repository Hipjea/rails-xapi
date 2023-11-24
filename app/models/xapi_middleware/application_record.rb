# frozen_string_literal: true

module XapiMiddleware
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
