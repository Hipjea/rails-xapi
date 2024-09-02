# frozen_string_literal: true

require "rails-xapi/version"
require "rails-xapi/engine"
require "rails-xapi/configuration"

module RailsXapi
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
