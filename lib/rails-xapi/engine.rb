# frozen_string_literal: true

module RailsXapi
  class Engine < ::Rails::Engine
    isolate_namespace RailsXapi

    initializer "local_helper.action_controller" do
      ActiveSupport.on_load :action_controller do
        helper RailsXapi::ApplicationHelper
      end
    end

<<<<<<< HEAD
    initializer :load_factories, after: "factory_bot.set_factory_paths" do
      if defined?(FactoryBot) && !Rails.env.production?
        FactoryBot.definition_file_paths.prepend(
          File.join(RailsXapi::Engine.root, "spec", "factories")
        )
      end
    end

=======
>>>>>>> 6f951bba9fea07eb45e19bb596af7a54ba23a187
    config.before_configuration do
      RailsXapi.configuration ||= RailsXapi::Configuration.new
    end

    config.i18n.default_locale = :en
    config.i18n.fallbacks = [:en]
  end
end
