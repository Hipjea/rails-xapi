# frozen_string_literal: true

# The optional structure for interactions or assessments.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#interaction-activities
class RailsXapi::InteractionActivity < ApplicationRecord
  belongs_to :activity_definition, class_name: "RailsXapi::ActivityDefinition"
  has_many :interaction_components, foreign_key: :interaction_activity_id

  INTERACTION_COMPONENT_TYPES = %w[scale choices source target steps]
  INTERACTION_KEYS =
    %w[interactionType correctResponsesPattern] + INTERACTION_COMPONENT_TYPES

  validates :interaction_type,
            presence: true,
            inclusion: {
              in: %w[
                true-false
                choice
                fill-in
                long-fill-in
                matching
                performance
                sequencing
                likert
                numeric
                other
              ]
            }

  attribute :correct_responses_pattern, :string, default: -> { [].to_json }

  def assign_interaction_components(interaction_attrs)
    return unless interaction_attrs.present?

    interaction_components.where(
      component_type: INTERACTION_COMPONENT_TYPES
    ).destroy_all

    INTERACTION_COMPONENT_TYPES.each do |component_type|
      Array(interaction_attrs[component_type]).each do |data|
        interaction_components.build(
          component_type: component_type,
          component_id: data["id"],
          description: data["description"].to_json,
          interaction_activity: self
        )
      end
    end
  end

  def correct_responses_pattern
    JSON.parse(super || "[]")
  end

  def correct_responses_pattern=(value)
    super(value.to_json)
  end

  def components_by_interaction_type
    case interaction_type
    when "likert"
      { "scale" => component_hash }
    when "choice"
      { "choice" => component_hash }
    else
      {}
    end
  end

  def as_json
    {
      interactionType: interaction_type,
      correctResponsesPattern: correct_responses_pattern
    }.merge(components_by_interaction_type)
  end

  private

  def component_hash
    interaction_components.map do |component|
      {
        "id" => component.component_id,
        "description" => component.parsed_description
      }
    end
  end
end

# == Schema Information
#
# Table name: rails_xapi_interaction_activities
#
#  id                        :integer          not null, primary key
#  correct_responses_pattern :text
#  interaction_type          :string           not null
#  activity_definition_id    :bigint           not null
#
# Indexes
#
#  idx_on_activity_definition_id_0cc615114b  (activity_definition_id)
#
