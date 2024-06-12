# frozen_string_literal: true

# Represents an account with home_page and name.
class XapiMiddleware::Account
  require "uri"

  attr_accessor :home_page, :name

  # Initializes a new Account instance.
  #
  # @param account [Hash] The account data.
  def initialize(account)
    validates_account(account)

    @home_page = account[:homePage]
    @name = account[:name]
  end

  # Validates the account data.
  #
  # @param [Hash] account The actor account data.
  # @raise [XapiMiddleware::Errors::XapiError] If the account home_page value provided is malformed.
  def validates_account(account)
    return if account[:homePage].blank?

    uri = URI.parse(account[:homePage])
    is_valid_home_page = uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    if !is_valid_home_page
      raise XapiMiddleware::Errors::XapiError,
        I18n.t("xapi_middleware.errors.malformed_account_home_page_url", url: account[:homePage])
    end
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
