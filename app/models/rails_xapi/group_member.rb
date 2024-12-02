# frozen_string_literal: true

class RailsXapi::GroupMember < ApplicationRecord
  belongs_to :group, class_name: "RailsXapi::Actor", dependent: :destroy
  belongs_to :actor, class_name: "RailsXapi::Actor", dependent: :destroy
end
