# frozen_string_literal: true

module RailsXapi
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
  end
end
