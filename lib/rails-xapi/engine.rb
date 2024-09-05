# frozen_string_literal: true

module RailsXapi
  class Engine < ::Rails::Engine
    isolate_namespace RailsXapi

    initializer "local_helper.action_controller" do
      ActiveSupport.on_load :action_controller do
        helper RailsXapi::ApplicationHelper
      end
    end

    config.before_configuration do
      RailsXapi.configuration ||= RailsXapi::Configuration.new
    end

    config.i18n.default_locale = :en
    config.i18n.fallbacks = [:en]
  end
end
