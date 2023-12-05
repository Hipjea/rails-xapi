# frozen_string_literal: true

module XapiMiddleware
  # Representation class of an error raised by the Actor class.
  class ActorError < StandardError; end

  class Actor
    # The Actor defines who performed the action. The Actor of a Statement can be an Agent or a Group.
    # See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#242-actor

    attr_accessor :object_type, :name, :mbox, :account, :openid

    OBJECT_TYPES = ["Agent", "Group"]

    # Initializes a new Actor instance.
    #
    # @param [String] object_type The type of the actor, either Agent or Group.
    # @param [String] name The name of the actor.
    # @param [String] mbox The mbox of the actor.
    # @param [String] openid The openid URI of the actor.
    # @param [Hash] account The account hash of the actor.
    def initialize(actor)
      validate_actor(actor)
      normalized_actor = normalize_actor(actor)

      @object_type = normalized_actor[:object_type]
      @name = normalized_actor[:name]
      @mbox = normalized_actor[:mbox] if normalized_actor[:mbox].present?
      @openid = actor[:openid] if actor[:openid].present?
      @account = Account.new(actor[:account]) if actor[:account].present?
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
      normalized_name = actor[:name].gsub(XapiMiddleware::Statement::LATIN_LETTERS_REGEX, "")
        .to_s
        .humanize
        .gsub(/\b('?[#{XapiMiddleware::Statement::LATIN_LETTERS}])/) { Regexp.last_match(1).capitalize }
      normalized_mbox = actor[:mbox].strip.downcase if actor[:mbox].present?

      {
        object_type: normalized_object_type,
        name: normalized_name,
        mbox: normalized_mbox
      }
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
        mbox_sha1sum: mbox_sha1sum,
        account: @account,
        openid: @openid
      }.compact
    end

    private

      # Produces the hex-encoded SHA1 hash of the actor mailto.
      #
      # @return [String] The hex-encoded SHA1 hash of the actor mailto.
      def mbox_sha1sum
        return nil if @mbox.blank?

        sha1 = Digest::SHA1.hexdigest(@mbox)
        "sha1:#{sha1}"
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
