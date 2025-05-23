# frozen_string_literal: true

# The optional structure for interactions or assessments.
# See: https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#interaction-components
class RailsXapi::InteractionComponent < ApplicationRecord
  belongs_to :interaction_activity, class_name: "RailsXapi::InteractionActivity"

  validates_with RailsXapi::Validators::LanguageMapValidator,
                 attributes: %i[description]

  def parsed_description
    return {} unless description.present?
    begin
      JSON.parse(description)
    rescue StandardError
      {}
    end
  end
end

# == Schema Information
#
# Table name: rails_xapi_interaction_components
#
#  id                      :integer          not null, primary key
#  component_type          :string           not null
#  description             :text
#  component_id            :string           not null
#  interaction_activity_id :bigint           not null
#
# Indexes
#
#  idx_on_interaction_activity_id_863e21bede  (interaction_activity_id)
#
