# frozen_string_literal: true

# The optional property context.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#246-context
class XapiMiddleware::Context < ApplicationRecord
  include Serializable

  belongs_to :instructor, class_name: "XapiMiddleware::Actor", optional: true
  belongs_to :team, class_name: "XapiMiddleware::Actor", optional: true
  belongs_to :statement_ref, class_name: "XapiMiddleware::Statement", optional: true
  belongs_to :statement, class_name: "XapiMiddleware::Statement", dependent: :destroy
  has_many :context_activities, dependent: :destroy
  has_many :extensions, as: :extendable, dependent: :destroy

  def contextActivities=(context_activities_hash)
    context_activities_hash.each do |activity_type, activities|
      activities.each do |activity|
        # Create the object and update it if necessary.
        object = XapiMiddleware::Object.find_or_create(activity) do
          object.activity_definition = activity[:definition] if activity[:definition].present?
        end
        object.update(activity)
        # Create the ContextActivity object.
        context_activity = XapiMiddleware::ContextActivity.new(activity_type: activity_type.to_s, object: object)
        context_activities << context_activity
      end
    end
  end

  def instructor=(value)
    i = XapiMiddleware::Actor.find_or_create_by(
      mbox: value[:mbox],
      mbox_sha1sum: value[:mbox_sha1sum],
      openid: value[:openid]
    ) do |actor|
      actor.name = value[:name] if value[:name].present?
      actor.account = value[:account].to_json if value[:account].present?
    end

    self[:instructor_id] = i.id if i.present?
  end

  def extensions=(extensions_data)
    extensions_data.each do |iri, data|
      extension = extensions.build(iri: iri)
      extension.value = serialized_value(data)
      extensions << extension
    end
  end
end

# == Schema Information
#
# Table name: xapi_middleware_contexts
#
#  id            :integer          not null, primary key
#  language      :string
#  platform      :string
#  registration  :string
#  revision      :string
#  statement_ref :bigint
#  instructor_id :bigint
#  statement_id  :bigint           not null
#  team_id       :bigint
#
# Indexes
#
#  index_xapi_middleware_contexts_on_instructor_id  (instructor_id)
#  index_xapi_middleware_contexts_on_statement_id   (statement_id)
#  index_xapi_middleware_contexts_on_statement_ref  (statement_ref)
#  index_xapi_middleware_contexts_on_team_id        (team_id)
#
