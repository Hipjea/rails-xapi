# frozen_string_literal: true

# The object optional definition.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#activity-definition
class XapiMiddleware::ObjectDefinition
  require "uri"

  attr_accessor :type, :name, :description, :extensions

  # Initializes a new ObjectDefinition instance.
  #
  # @param [Hash] definition The object definition hash.
  def initialize(definition)
    validate_definition(definition)
    normalized_definition = normalize_definition(definition)

    @type = normalized_definition[:type]
    @name = {}
    @description = {}
    @extensions = {}

    add_values_to_key(definition[:name], @name)
    add_values_to_key(definition[:description], @description)
    add_values_to_key(definition[:extensions], @extensions)
  end

  # Validates the object definition data.
  #
  # @param [Hash] definition The object definition data.
  def validate_definition(definition)
    if definition[:type].present?
      uri = URI.parse(definition[:type].strip)
      is_valid_type = uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

      if !is_valid_type
        raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.malformed_uri", uri: definition[:type])
      end
    end
  end

  # Normalizes the object definition data.
  #
  # @param [Hash] definition The object definition data.
  # @return [Hash] The normalized object definition data.
  def normalize_definition(definition)
    normalized_type = definition[:type].to_s.strip

    {type: normalized_type}
  end

  # Adds values to the corresponding key, to allow multiple languages values.
  #
  # @param [Hash] attr The hash attribute that contains the values.
  # @param [Hash] key The hash attribute to be defined.
  def add_values_to_key(attr, key)
    if attr.is_a?(Hash) && attr.any?
      attr.each do |k, v|
        key[k.to_sym] = v
      end
    end
  end

  # Overrides the Hash class method.
  #
  # @return [Hash] The object definition hash.
  def to_hash
    {
      type: @type,
      name: @name,
      description: @description,
      extensions: @extensions
    }.compact
  end
end
