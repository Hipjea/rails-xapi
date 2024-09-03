# frozen_string_literal: true

# The optional context activity.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#246-context
class RailsXapi::ContextActivity < ApplicationRecord
  belongs_to :context, class_name: "RailsXapi::Context"
  belongs_to :object, class_name: "RailsXapi::Object"

  validates :activity_type, presence: true, inclusion: {in: ["parent", "grouping", "category", "other"]}
end

# == Schema Information
#
# Table name: rails_xapi_context_activities
#
#  id            :integer          not null, primary key
#  activity_type :string           not null
#  context_id    :bigint           not null
#  object_id     :string           not null
#
# Indexes
#
#  index_rails_xapi_context_activities_on_context_id  (context_id)
#  index_rails_xapi_context_activities_on_object_id   (object_id)
#
