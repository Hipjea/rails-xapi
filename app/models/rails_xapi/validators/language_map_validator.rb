# frozen_string_literal: true

module RailsXapi
  module Validators
    class LanguageMapValidator < ActiveModel::Validator
      LANGUAGE_MAP_REGEX = /\A[a-z]{2}(-[A-Z]{2})?\z/

      def validate(record)
        attributes_to_validate = options[:attributes] || []

        attributes_to_validate.each do |attribute|
          next unless record.respond_to?(attribute)

          raw_value = record.public_send(attribute)
          next unless raw_value.present?

          validate_language_map_keys(record, attribute, raw_value)
        end
      end

      private

      def validate_language_map_keys(record, attribute, data)
        data_hash =
          case data
          when String
            # If it's a string, parse:
            begin
              JSON.parse(data)
            rescue JSON::ParserError
              record.errors.add(
                attribute,
                I18n.t("rails_xapi.errors.invalid_json")
              )
              return
            end
          when Hash
            data
          else
            record.errors.add(attribute, "must be a JSON string or a Hash")
            return
          end

        invalid_keys =
          data_hash.keys.reject { |key| key.match?(LANGUAGE_MAP_REGEX) }

        if invalid_keys.any?
          record.errors.add(
            attribute,
            I18n.t(
              "rails_xapi.errors.definition_description_invalid_keys",
              values: invalid_keys.join(", ")
            )
          )
        end
      end
    end
  end
end
