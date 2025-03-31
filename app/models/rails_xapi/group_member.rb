# frozen_string_literal: true

class RailsXapi::GroupMember < ApplicationRecord
  belongs_to :group, class_name: "RailsXapi::Actor", dependent: :destroy
  belongs_to :actor, class_name: "RailsXapi::Actor", dependent: :destroy
end

# == Schema Information
#
# Table name: rails_xapi_group_members
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  actor_id   :bigint           not null
#  group_id   :bigint           not null
#
# Indexes
#
#  index_rails_xapi_group_members_on_actor_id  (actor_id)
#  index_rails_xapi_group_members_on_group_id  (group_id)
#
