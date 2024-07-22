# frozen_string_literal: true

# The Object defines the thing that was acted on.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#244-object
# The Object of a Statement can be an Activity, Agent/Group, SubStatement, or Statement Reference.
class XapiMiddleware::Object < ApplicationRecord
  OBJECT_TYPES = ["Activity", "Agent", "Group", "SubStatement", "StatementRef"]

  attr_accessor :actor, :verb, :object, :result, :context, :timestamp

  has_one :definition, class_name: "XapiMiddleware::ActivityDefinition", dependent: :destroy
  has_many :statements, class_name: "XapiMiddleware::Statement", dependent: :nullify
  belongs_to :statement, class_name: "XapiMiddleware::Statement", optional: true

  validates :statement, presence: true, if: -> { object_type == "SubStatement" }

  after_initialize :set_defaults
  before_validation :create_statement_for_substatement

  def objectType=(value)
    self.object_type = value.presence || "Activity"
  end

  private

  def set_defaults
    self.object_type ||= "Activity"
  end

  def create_statement_for_substatement
    return unless object_type == "SubStatement" && statement.nil?

    # We need to generate a random primary key in place of the object ID
    self.id = Digest::SHA1.hexdigest([Time.zone.now, rand(111..999)].join)
    # Then, we can create the substatement
    substatement_verb = XapiMiddleware::Verb.find_or_create_by(id: verb[:id]) do |v|
      v.attributes = verb
    end
    substatement_actor = XapiMiddleware::Actor.by_iri_or_create(actor) do |a|
      a.attributes = actor
    end
    substatement_object = XapiMiddleware::Object.find_or_create_by(id: object[:id]) do |o|
      o.attributes = object
    end

    self.statement = XapiMiddleware::Statement.create(
      actor: substatement_actor,
      verb: substatement_verb,
      object: substatement_object
    )

    statement.save!
  end
end

# == Schema Information
#
# Table name: xapi_middleware_objects
#
#  id           :string           not null, primary key
#  object_type  :string           not null
#  statement_id :bigint
#
# Indexes
#
#  index_xapi_middleware_objects_on_id            (id) UNIQUE
#  index_xapi_middleware_objects_on_statement_id  (statement_id)
#
