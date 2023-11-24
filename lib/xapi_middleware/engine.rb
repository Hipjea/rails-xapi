# frozen_string_literal: true

module XapiMiddleware
  class Engine < ::Rails::Engine
    isolate_namespace XapiMiddleware

    config.before_configuration do
      XapiMiddleware.configuration ||= XapiMiddleware::Configuration.new
    end

    config.i18n.default_locale = :en
    config.i18n.fallbacks = [:en]
  end
end
