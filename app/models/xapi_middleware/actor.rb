# frozen_string_literal: true

module XapiMiddleware
  # Representation class of an error raised by the Actor class.
  class ActorError < StandardError; end

  class Actor
    attr_accessor :name, :mbox

    # Initializes a new Actor instance.
    #
    # @param [String] name The name of the actor.
    # @param [String] mbox The mbox of the actor.
    def initialize(actor)
      validate_actor(actor)
      normalized_actor = normalize_actor(actor)

      @name = normalized_actor[:name]
      @mbox = normalized_actor[:mbox] if normalized_actor[:mbox].present?
    end

    # Validates the actor data.
    #
    # @param [Hash] actor The actor data.
    def validate_actor(actor)
      if actor[:mbox].present?
        raise ActorError, I18n.t("xapi_middleware.errors.malformed_mbox") unless actor[:mbox].strip =~ /\Amailto:([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/
      end
    end

    # Class method to normalize actor data.
    #
    # @param [Hash] actor The actor data.
    # @return [Hash] The normalized actor data.
    def normalize_actor(actor)
      normalized_name = actor[:name].gsub(XapiMiddleware::Statement::LATIN_LETTERS_REGEX, "")
        .to_s
        .humanize
        .gsub(/\b('?[#{XapiMiddleware::Statement::LATIN_LETTERS}])/) { Regexp.last_match(1).capitalize }

      normalized_mbox = actor[:mbox].strip.downcase if actor[:mbox].present?

      {name: normalized_name, mbox: normalized_mbox}
    end
  end
end
