# frozen_string_literal: true

# The optional property context.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#246-context
class RailsXapi::Context < ApplicationRecord
  include Serializable

  belongs_to :instructor, class_name: "RailsXapi::Actor", optional: true
  belongs_to :team, class_name: "RailsXapi::Actor", optional: true
  belongs_to :statement_ref, class_name: "RailsXapi::Statement", optional: true
  belongs_to :statement, class_name: "RailsXapi::Statement", dependent: :destroy
  has_many :context_activities, dependent: :destroy
  has_many :extensions, as: :extendable, dependent: :destroy

  def contextActivities=(context_activities_hash)
    context_activities_hash.each do |activity_type, activities|
      activities.each do |activity|
        # Create the object and update it if necessary.
        object = RailsXapi::Object.find_or_create(activity) do
          object.activity_definition = activity[:definition] if activity[:definition].present?
        end
        object.update(activity)
        # Create the ContextActivity object.
        context_activity = RailsXapi::ContextActivity.new(activity_type: activity_type.to_s, object: object)
        context_activities << context_activity
      end
    end
  end

  # Set the instructor value and create the actor if provided.
  def instructor=(value)
    actor_row = find_or_create_actor_with_account(value)
    self[:instructor_id] = actor_row.id if actor_row&.id.present?
  end

  # Set the team value and create the actor if provided.
  def team=(value)
    actor_row = find_or_create_actor_with_account(value)
    self[:team_id] = actor_row.id if actor_row&.id.present?
  end

  # Set the statement_ref value if provided.
  def statement=(value)
    id = value[:id]
    return if id.nil? || value[:objectType] != "StatementRef"

    statement_row = RailsXapi::Statement.find_by(id: id)
    self[:statement_ref] = statement_row.id if statement_row&.id.present?
  end

  def extensions=(extensions_data)
    extensions_data.each do |iri, data|
      extension = extensions.build(iri: iri)
      extension.value = serialized_value(data)
      extensions << extension
    end
  end

  private

  def find_or_create_actor_with_account(value)
    home_page = value.dig(:account, :homePage)
    existing_account = RailsXapi::Account.find_by(home_page: home_page) if home_page.present?

    # Set the params to search an existing row.
    actor_params = {
      mbox: value[:mbox],
      mbox_sha1sum: value[:mbox_sha1sum],
      openid: value[:openid]
    }
    actor_params[:account] = existing_account if existing_account.present?

    RailsXapi::Actor.find_or_create_by(actor_params) do |actor|
      actor.name = value[:name] if value[:name].present?
      actor.account = RailsXapi::Account.new(value[:account]) if value[:account].present?
    end
  end
end

# == Schema Information
#
# Table name: rails_xapi_contexts
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
#  index_rails_xapi_contexts_on_instructor_id  (instructor_id)
#  index_rails_xapi_contexts_on_statement_id   (statement_id)
#  index_rails_xapi_contexts_on_statement_ref  (statement_ref)
#  index_rails_xapi_contexts_on_team_id        (team_id)
#
