# frozen_string_literal: true

# The Object defines the thing that was acted on.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#244-object
# The Object of a Statement can be an Activity, Agent/Group, SubStatement, or Statement Reference.
class XapiMiddleware::Object < ApplicationRecord
  OBJECT_TYPES = ["Activity", "Agent", "Group", "SubStatement", "StatementRef"]

  attr_accessor :objectType, :actor, :verb, :object, :result, :context, :timestamp

  has_one :definition, class_name: "XapiMiddleware::ActivityDefinition", dependent: :destroy
  has_many :statements, class_name: "XapiMiddleware::Statement", dependent: :nullify
  belongs_to :statement, class_name: "XapiMiddleware::Statement", optional: true

  validates :id, presence: true
  validates :object_type, presence: true, inclusion: {in: OBJECT_TYPES}
  validates :statement, presence: true, if: -> { object_type == "SubStatement" }
  validates :actor, presence: true, if: -> { object_type == "SubStatement" }
  validates :object, presence: true, if: -> { object_type == "SubStatement" }
  validates :verb, presence: true, if: -> { object_type == "SubStatement" }

  before_validation :set_defaults, :create_statement_for_substatement

  accepts_nested_attributes_for :definition

  def definition=(definition_hash)
    if definition_hash.present?
      # Build or create the associated object.
      build_definition(definition_hash) if definition.nil?
      definition.attributes = definition_hash
    else
      self.definition = nil
    end
  end

  # Find an Object by its id or create a new one.
  #
  # @param [Hash] attributes The attributes of the requested object.
  # @return [XapiMiddleware::Object] The found or created object.
  def self.find_or_create(attributes)
    find_by(id: attributes[:id]) || create(attributes)
  end

  # Update the Activity Definition if existing.
  def update_definition(definition_data)
    if definition_data.present?
      definition = self.definition || create_definition
      definition.update(definition_data)
    end
  end

  private

  def set_defaults
    self.object_type = objectType.presence || "Activity"

    if new_record? && object_type == "SubStatement"
      self.actor = actor
      self.verb = verb
      self.object = object
      self.result = result
      self.context = context
      self.timestamp = timestamp
    end
  end

  def create_statement_for_substatement
    return unless object_type == "SubStatement" && statement.nil?

    # We need to generate a random primary key in place of the object ID
    self.id = Digest::SHA1.hexdigest([Time.zone.now, rand(111..999)].join)

    # Then, we can create the substatement
    substatement_actor = create_or_find_actor
    substatement_verb = create_or_find_verb
    substatement_object = create_or_find_object
    substatement_result = create_result
    substatement_context = create_context

    self.statement = XapiMiddleware::Statement.create!(
      actor: substatement_actor,
      verb: substatement_verb,
      object: substatement_object,
      result: substatement_result,
      context: substatement_context,
      timestamp: timestamp
    )
  end

  def create_or_find_actor
    raise XapiMiddleware::Errors::XapiError, I18n.t("xapi_middleware.errors.missing_actor") if actor.blank?

    XapiMiddleware::Actor.by_iri_or_create(actor)
  end

  def create_or_find_verb
    XapiMiddleware::Verb.find_or_create_by(id: verb[:id]) do |v|
      v.attributes = verb
    end
  end

  def create_or_find_object
    XapiMiddleware::Object.find_or_create_by(id: object[:id]) do |o|
      o.attributes = object
    end
  end

  def create_result
    XapiMiddleware::Result.new(result) if result.present?
  end

  def create_context
    XapiMiddleware::Context.new(context)
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
