# frozen_string_literal: true

# The Actor defines who performed the action.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#242-actor
class XapiMiddleware::Actor < ApplicationRecord
  require "uri"

  belongs_to :account, class_name: "XapiMiddleware::Account", foreign_key: "xapi_middleware_account_id", optional: true
  has_many :statements, class_name: "XapiMiddleware::Statement", dependent: :nullify

  validates :object_type, presence: true
  validate :validate_actor_ifi_presence

  OBJECT_TYPES = ["Agent", "Group"]

  def objectType=(value)
    self.object_type = value
  end

  private

  def validate_actor_ifi_presence
    unless mbox.present? || mbox_sha1sum.present? || openid.present? || account.present?
      errors.add(:base, I18n.t("xapi_middleware.errors.actor_ifi_must_be_present"))
    end
  end

  # Normalizes the actor data.
  #
  # @param [Hash] actor The actor data.
  # @return [Hash] The normalized actor data.
  def normalize_actor(actor)
    normalized_object_type = actor[:objectType].presence || OBJECT_TYPES.first

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

  private_class_method def self.validate_mbox(mbox)
    mbox_valid = mbox.strip =~ /\Amailto:([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/
    raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.malformed_mbox", name: mbox) unless mbox_valid

    true
  end

  private_class_method def self.validate_mbox_sha1sum(mbox_sha1sum)
    raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.malformed_mbox_sha1sum") unless is_sha1?(mbox_sha1sum)

    true
  end

  private_class_method def self.validate_object_type(object_type)
    object_type_valid = OBJECT_TYPES.include?(object_type)
    raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.invalid_actor_object_type", name: object_type) unless object_type_valid

    true
  end

  private_class_method def self.validate_openid(openid)
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
#  id                         :integer          not null, primary key
#  mbox                       :string
#  mbox_sha1sum               :string
#  name                       :string
#  object_type                :string
#  openid                     :string
#  created_at                 :datetime         not null
#  xapi_middleware_account_id :integer
#
# Indexes
#
#  index_xapi_middleware_actors_on_xapi_middleware_account_id  (xapi_middleware_account_id)
#
