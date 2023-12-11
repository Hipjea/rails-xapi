# frozen_string_literal: true

module XapiMiddleware
  # Representation class of an error raised by the Actor class.
  class ActorError < StandardError; end

  class Actor
    # The Actor defines who performed the action.
    # See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#242-actor
    # The Actor of a Statement can be an Agent or a Group.
    OBJECT_TYPES = ["Agent", "Group"]

    attr_accessor :object_type, :name, :mbox, :account, :openid

    # Initializes a new Actor instance.
    #
    # @param [String] object_type The type of the actor, either Agent or Group.
    # @param [String] name The name of the actor.
    # @param [String] mbox The mbox of the actor.
    # @param [String] mbox_sha1sum The sha1 encoded mbox value of the actor.
    # @param [String] openid The openid URI of the actor.
    # @param [Hash] account The account hash of the actor.
    def initialize(actor)
      validate_actor(actor)
      normalized_actor = normalize_actor(actor)

      @object_type = normalized_actor[:object_type]
      @name = normalized_actor[:name] if normalized_actor[:name].present?

      mbox_present = normalized_actor[:mbox].present?
      mbox_sha1sum_present = actor[:mbox_sha1sum].present?
      openid_present = actor[:openid].present?
      account_present = actor[:account].present?

      if mbox_present || mbox_sha1sum_present || openid_present || account_present
        @mbox = normalized_actor[:mbox] if mbox_present
        @mbox_sha1sum = normalized_actor[:mbox_sha1sum] if mbox_sha1sum_present
        @openid = actor[:openid] if openid_present
        @account = Account.new(actor[:account]) if account_present
      else
        raise ActorError, I18n.t("xapi_middleware.errors.actor_ifi_must_be_present")
      end
    end

    # Validates the actor data.
    #
    # @param [Hash] actor The actor data.
    def validate_actor(actor)
      if actor[:mbox].present?
        mbox_valid = actor[:mbox].strip =~ /\Amailto:([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/
        raise ActorError, I18n.t("xapi_middleware.errors.malformed_mbox", name: actor[:mbox]) unless mbox_valid
      end

      if actor[:mbox_sha1sum].present?
        raise ActorError, I18n.t("xapi_middleware.errors.malformed_mbox_sha1sum") unless is_sha1?(actor[:mbox_sha1sum])
      end

      if actor[:object_type].present?
        object_type_valid = OBJECT_TYPES.include?(actor[:object_type])
        raise ActorError, I18n.t("xapi_middleware.errors.invalid_actor_object_type", name: actor[:object_type]) unless object_type_valid
      end

      if actor[:openid].present?
        uri = URI.parse(actor[:openid])
        is_valid_openid_uri = uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

        raise ActorError, I18n.t("xapi_middleware.errors.malformed_openid_uri", uri: actor[:openid]) unless is_valid_openid_uri
      end
    end

    # Normalizes the actor data.
    #
    # @param [Hash] actor The actor data.
    # @return [Hash] The normalized actor data.
    def normalize_actor(actor)
      normalized_object_type = (actor[:object_type].presence || OBJECT_TYPES.first)

      if actor[:name].present?
        normalized_name = actor[:name].gsub(XapiMiddleware::Statement::LATIN_LETTERS_REGEX, "")
          .to_s
          .humanize
          .gsub(/\b('?[#{XapiMiddleware::Statement::LATIN_LETTERS}])/) { Regexp.last_match(1).capitalize }
      end

      normalized_mbox = actor[:mbox].strip.downcase if actor[:mbox].present?

      {
        object_type: normalized_object_type,
        name: normalized_name,
        mbox: normalized_mbox
      }.compact
    end

    # Overrides the Hash class method to camelize object_type, according to the xAPI specification.
    # See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#part-two-experience-api-data
    #
    # @return [Hash] The actor hash with the camel-case version of object_type.
    def to_hash
      {
        objectType: @object_type,
        name: @name,
        mbox: @mbox,
        mbox_sha1sum: @mbox_sha1sum,
        account: @account,
        openid: @openid
      }.compact
    end

    private

      # Produces the hex-encoded SHA1 hash of the actor mailto.
      #
      # @param [String] mbox The mbox clear value to be encoded.
      # @return [Boolean] True if the value is matching, false otherwise.
      def is_sha1?(str)
        # SHA-1 hash is a 40-character hexadecimal string
        # consisting of numbers 0-9 and letters a-f
        !!(str =~ /^sha1:[0-9a-f]{40}$/i)
      end
  end

  # Represents an account with home_page and name.
  class Account
    attr_accessor :home_page, :name

    # Initializes a new Account instance.
    #
    # @param account [Hash] The account data.
    def initialize(account)
      validates_account(account)

      @home_page = account[:home_page]
      @name = account[:name]
    end

    # Validates the account data.
    #
    # @param [Hash] account The actor account data.
    # @raise [ActorError] If the account home_page value provided is malformed.
    def validates_account(account)
      return if account[:home_page].blank?

      uri = URI.parse(account[:home_page])
      is_valid_home_page = uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

      raise ActorError, I18n.t("xapi_middleware.errors.malformed_account_home_page_url", url: account[:home_page]) unless is_valid_home_page
    end

    # Overrides the Hash class method to camelize home_page, according to the xAPI specification.
    # See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#2424-account-object
    #
    # @return [Hash] The account hash with the camel-case version of home_page, if home_page is provided.
    def to_hash
      {
        homePage: @home_page,
        name: @name
      }.compact
    end
  end
end
