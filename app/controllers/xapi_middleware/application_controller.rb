# frozen_string_literal: true

module XapiMiddleware
  class ApplicationController < ActionController::Base
    protect_from_forgery
  end
end
