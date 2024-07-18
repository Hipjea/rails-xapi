# frozen_string_literal: true

# The Object defines the thing that was acted on.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#244-object
# The Object of a Statement can be an Activity, Agent/Group, SubStatement, or Statement Reference.
class XapiMiddleware::Object < ApplicationRecord
  OBJECT_TYPES = ["Activity", "Agent", "Group", "SubStatement", "StatementRef"]

  has_one :definition, class_name: "XapiMiddleware::ActivityDefinition", dependent: :destroy
  has_many :statements, class_name: "XapiMiddleware::Statement", dependent: :nullify

  after_initialize :set_defaults

  def objectType=(value)
    self.object_type = value
  end

  private

  def set_defaults
    self.object_type ||= "Activity"
  end
end

# == Schema Information
#
# Table name: xapi_middleware_objects
#
#  id          :string           not null, primary key
#  object_type :string           not null
#
# Indexes
#
#  index_xapi_middleware_objects_on_id  (id) UNIQUE
#
