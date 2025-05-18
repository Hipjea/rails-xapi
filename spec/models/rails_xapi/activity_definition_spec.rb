# spec/models/rails_xapi/activity_definition_spec.rb

require "rails_helper"

describe RailsXapi::ActivityDefinition do
  let(:statement) { build(:statement) }
  let(:definition_with_type) { build(:activity_definition, :with_type) }
  let(:definition_with_invalid_description) do
    build(:activity_definition, :with_invalid_description)
  end

  it "is valid" do
    statement.object.definition = {
      name: {
        "en-US" => "Definition name"
      },
      description: {
        "en-US" =>
          "A simple Experience API statement. Note that the LRS does not need to have any prior information about the Actor (learner), the verb, or the Activity/object."
      }
    }
    statement.save!

    expect(statement.object.definition.as_json).to eq(
      {
        name: { "en-US" => "Definition name" }.to_json,
        description: {
          "en-US" =>
            "A simple Experience API statement. Note that the LRS does not need to have any prior information about the Actor (learner), the verb, or the Activity/object."
        }.to_json,
        type: nil
      }
    )

    expect(statement).to be_valid
  end

  it "raises an exception" do
    statement.object.definition = {
      name: {
        "en-US" => "Definition name"
      },
      # Add a description missing a language map.
      description:
        "A simple Experience API statement. Note that the LRS
        does not need to have any prior information about the Actor (learner), the
        verb, or the Activity/object."
    }

    expect { statement.valid? }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t(
           "rails_xapi.errors.attribute_must_be_a_valid_language_map",
           name: "description"
         )
    end
  end

  it "sets the type attribute" do
    expect(definition_with_type.activity_type).not_to be_nil
    expect(definition_with_type.type).not_to be_nil
  end

  it "is not valid with an incorrect description language map key" do
    expect { definition_with_invalid_description.valid? }.to raise_error(
      RailsXapi::Errors::XapiError,
      I18n.t(
        "rails_xapi.errors.attribute_must_be_a_valid_language_map",
        name: :description
      )
    )
  end
end

# == Schema Information
#
# Table name: rails_xapi_activity_definitions
#
#  id            :integer          not null, primary key
#  activity_type :string
#  description   :text
#  more_info     :text
#  name          :string
#  object_id     :string           not null
#
# Indexes
#
#  index_rails_xapi_activity_definitions_on_object_id  (object_id)
#
