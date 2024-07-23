# frozen_string_literal: true

# The Actor defines who performed the action.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#242-actor
class XapiMiddleware::Actor < ApplicationRecord
  require "uri"
  include Serializable

  OBJECT_TYPES = ["Agent", "Group"]

  attr_accessor :objectType

  has_one :account, class_name: "XapiMiddleware::Account", dependent: :destroy
  has_many :statements, class_name: "XapiMiddleware::Statement", dependent: :nullify

  validates :object_type, presence: true
  validate :validate_actor_ifi_presence, :validate_mbox, :validate_mbox_sha1sum, :validate_object_type, :validate_openid

  after_initialize :set_defaults
  before_validation :normalize_actor

  # Build the Actor object from the given data and user email.
  #
  # @param [Hash] data The data used to build the actor object, including optional nested account data.
  # @param [String] user_email The optional email address to be included in the `mbox` field of the data.
  # @return [XapiMiddleware::Actor] The actor object initialized with the data.
  def self.build_from_data(data, user_email = nil)
    data = data.merge(mbox: "mailto:#{user_email}") if user_email.present?
    data = handle_account_data(data)

    conditions = data.slice(:mbox, :mbox_sha1sum, :openid).compact
    where(conditions).first_or_initialize
  end

  # Find an Actor by its identifiers or create a new one.
  #
  # @param [Hash] data The data to find or create the actor.
  # @return [XapiMiddleware::Actor] The found or created actor object.
  def self.by_iri_or_create(data)
    data = handle_account_data(data)

    actor = find_or_create_by(mbox: data[:mbox], mbox_sha1sum: data[:mbox_sha1sum], openid: data[:openid]) do |a|
      a.attributes = data
    end

    raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.invalid_actor") unless actor.valid?

    actor
  end

  private

  def set_defaults
    # We need to match the camel case notation from JSON data.
    self.object_type = objectType.presence || "Agent"
  end

  # Normalizes the actor data.
  #
  # @param [Hash] actor The actor data.
  # @return [Hash] The normalized actor data.
  def normalize_actor
    self.object_type = object_type.presence || OBJECT_TYPES.first

    if name.present?
      self.name = name.gsub(Serializable::LATIN_LETTERS_REGEX, "")
        .to_s
        .humanize
        .gsub(/\b('?[#{Serializable::LATIN_LETTERS}])/) { Regexp.last_match(1).capitalize }
    end

    self.mbox = mbox.strip.downcase if mbox.present?
  end

  # Find an Account by its identifier or create a new one and set the actor's data.
  #
  # @param [Hash] data The data to find or create the account.
  # @return [Hash] The actor's data.
  private_class_method def self.handle_account_data(data)
    if (account_data = data[:account]).present?
      account = XapiMiddleware::Account.find_or_create_by(home_page: account_data[:homePage]) do |a|
        a.name = account_data[:name]
      end

      data[:account] = account
      data[:name] ||= account_data[:name]
    end

    data
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

  def validate_actor_ifi_presence
    unless mbox.present? || mbox_sha1sum.present? || openid.present? || account.present?
      raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.actor_ifi_must_be_present")
    end
  end

  def validate_mbox
    return if mbox.blank?

    mbox_valid = mbox.strip =~ /\Amailto:([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/
    raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.malformed_mbox", name: mbox) unless mbox_valid

    true
  end

  def validate_mbox_sha1sum
    return if mbox_sha1sum.blank?

    raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.malformed_mbox_sha1sum") unless is_sha1?(mbox_sha1sum)

    true
  end

  def validate_object_type
    object_type_valid = OBJECT_TYPES.include?(object_type)
    raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.invalid_actor_object_type", name: object_type) unless object_type_valid

    true
  end

  def validate_openid
    return if openid.blank?

    uri = URI.parse(openid)
    is_valid_openid_uri = uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.malformed_openid_uri", uri: openid) unless is_valid_openid_uri

    true
  end

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

# == Schema Information
#
# Table name: xapi_middleware_actors
#
#  id           :integer          not null, primary key
#  mbox         :string
#  mbox_sha1sum :string
#  name         :string
#  object_type  :string
#  openid       :string
#  created_at   :datetime         not null
#  account_id   :bigint
#
# Indexes
#
#  index_xapi_middleware_actors_on_account_id  (account_id)
#
