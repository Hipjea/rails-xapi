# frozen_string_literal: true

# The Object defines the thing that was acted on.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#244-object
# The Object of a Statement can be an Activity, Agent/Group, SubStatement, or Statement Reference.
class XapiMiddleware::Object < ApplicationRecord
  OBJECT_TYPES = ["Activity", "Agent", "Group", "SubStatement", "StatementRef"]

  # has_one :activity_definition, class_name: "XapiMiddleware::AcvitityDefinition", dependent: :destroy
  has_one :definition, class_name: "XapiMiddleware::ActivityDefinition", dependent: :destroy
  has_many :statements, class_name: "XapiMiddleware::Statement", dependent: :nullify

  attribute :object_type, :string, default: -> { OBJECT_TYPES.first }
end

# == Schema Information
#
# Table name: xapi_middleware_objects
#
#  id          :integer          not null, primary key
#  description :string
#  extensions  :text
#  more_info   :text
#  name        :string
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
