# frozen_string_literal: true

module RailsXapi
  class Engine < ::Rails::Engine
    isolate_namespace RailsXapi

    config.before_configuration do
      RailsXapi.configuration ||= RailsXapi::Configuration.new
    end

    config.i18n.default_locale = :en
    config.i18n.fallbacks = [:en]
  end
end
