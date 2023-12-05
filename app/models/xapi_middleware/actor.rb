# frozen_string_literal: true

module XapiMiddleware
  # Representation class of an error raised by the Actor class.
  class ActorError < StandardError; end

  class Actor
    attr_accessor :object_type, :name, :mbox, :account

    OBJECT_TYPES = ["Agent", "Group"]

    # Initializes a new Actor instance.
    #
    # @param [String] object_type The type of the actor, either Agent or Group.
    # @param [String] name The name of the actor.
    # @param [String] mbox The mbox of the actor.
    def initialize(actor)
      validate_actor(actor)
      normalized_actor = normalize_actor(actor)

      @object_type = normalized_actor[:object_type]
      @name = normalized_actor[:name]
      @mbox = normalized_actor[:mbox] if normalized_actor[:mbox].present?
      @account = normalized_actor[:account] if normalized_actor[:account].present?
    end

    # Validates the actor data.
    #
    # @param [Hash] actor The actor data.
    def validate_actor(actor)
      if actor[:mbox].present?
        mbox_valid = actor[:mbox].strip =~ /\Amailto:([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/
        raise ActorError, I18n.t("xapi_middleware.errors.malformed_mbox", name: actor[:mbox]) unless mbox_valid
      end

      if actor[:object_type].present?
        object_type_valid = OBJECT_TYPES.include?(actor[:object_type])
        raise ActorError, I18n.t("xapi_middleware.errors.invalid_actor_object_type", name: actor[:object_type]) unless object_type_valid
      end
    end

    # Class method to normalize actor data.
    #
    # @param [Hash] actor The actor data.
    # @return [Hash] The normalized actor data.
    def normalize_actor(actor)
      normalized_object_type = (actor[:object_type].presence || OBJECT_TYPES.first)
      normalized_name = actor[:name].gsub(XapiMiddleware::Statement::LATIN_LETTERS_REGEX, "")
        .to_s
        .humanize
        .gsub(/\b('?[#{XapiMiddleware::Statement::LATIN_LETTERS}])/) { Regexp.last_match(1).capitalize }
      normalized_mbox = actor[:mbox].strip.downcase if actor[:mbox].present?
      normalized_account = actor[:account] if actor[:account].present?

      {
        object_type: normalized_object_type,
        name: normalized_name,
        mbox: normalized_mbox,
        account: normalized_account
      }
    end

    # Overrides the Hash class method to camelize object_type,
    # according to the xAPI specification.
    #
    # See https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#part-two-experience-api-data
    #
    # @return [Hash] The actor hash with the camel-case version of object_type.
    #
    def to_hash
      {
        objectType: @object_type,
        name: @name,
        mbox: @mbox,
        account: @account
      }
    end
  end
end
