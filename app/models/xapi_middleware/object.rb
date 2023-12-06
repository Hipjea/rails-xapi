# frozen_string_literal: true

module XapiMiddleware
  # Representation class of an error raised by the Object class.
  class ObjectError < StandardError; end

  class Object
    # The Object defines the thing that was acted on.
    # See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#244-object
    # The Object of a Statement can be an Activity, Agent/Group, SubStatement, or Statement Reference.
    OBJECT_TYPES = ["Activity", "Agent", "Group", "SubStatement", "StatementRef"]

    attr_accessor :object_type, :id, :definition

    # Initializes a new Object instance.
    #
    # @param [Hash] object The object hash containing id and name.
    def initialize(object)
      validate_object(object)
      normalized_object = normalize_object(object)

      @object_type = normalized_object[:object_type]
      @id = object[:id].presence
      @definition = object[:name].present? ? Definition.new(name: object[:name]) : nil

      @verb = normalized_object[:verb].presence
      @object = normalized_object[:object].presence
      @actor = normalized_object[:actor].presence
    end

    # Validates the object data.
    #
    # @param [Hash] object The object data.
    def validate_object(object)
      object_type = object[:object_type]

      if object_type.present?
        object_type_valid = OBJECT_TYPES.include?(object_type)
        raise ObjectError, I18n.t("xapi_middleware.errors.invalid_object_object_type", name: object_type) unless object_type_valid
      end

      if object_type.present? && object_type == "SubStatement"
        is_valid_substatement = object[:actor].present? && object[:object].present? && object[:verb].present?
        raise ObjectError, I18n.t("xapi_middleware.errors.invalid_object_substatement") unless is_valid_substatement
      end
    end

    # Normalizes the object data.
    #
    # @param [Hash] object The actor data.
    # @return [Hash] The normalized object data.
    def normalize_object(object)
      normalized_object_type = (object[:object_type].presence || OBJECT_TYPES.first)
      normalize_substatement_verb, normalize_substatement_object, normalize_substatement_actor = nil

      if normalized_object_type == "SubStatement"
        normalize_substatement_verb = object[:verb]
        normalize_substatement_object = object[:object]
        normalize_substatement_actor = object[:actor]
      end

      {
        object_type: normalized_object_type,
        verb: normalize_substatement_verb,
        object: normalize_substatement_object,
        actor: normalize_substatement_actor
      }.compact
    end

    # Overrides the Hash class method.
    #
    # @return [Hash] The object hash.
    def to_hash
      {
        object_type: @object_type,
        id: @id,
        definition: @definition,
        verb: @verb,
        object: @object,
        actor: @actor
      }.compact
    end
  end

  class Definition
    attr_accessor :name

    # Initializes a new Definition instance.
    #
    # @param [String] name The name of the definition.
    def initialize(name:)
      @name = name
    end

    # Overrides the Hash class method.
    #
    # @return [Hash] The definition hash.
    def to_hash
      {name: @name}.compact
    end
  end
end
