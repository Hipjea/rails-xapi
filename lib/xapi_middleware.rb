require "xapi_middleware/version"
require "xapi_middleware/engine"
require "xapi_middleware/configuration"

module XapiMiddleware
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
