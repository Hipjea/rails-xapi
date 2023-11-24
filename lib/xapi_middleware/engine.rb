module XapiMiddleware
  class Engine < ::Rails::Engine
    isolate_namespace XapiMiddleware

    config.i18n.default_locale = :en
    config.i18n.fallbacks = [:en]
  end
end
