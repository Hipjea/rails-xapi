# spec/models/rails_xapi/object_spec.rb

require "rails_helper"

describe RailsXapi::Object do
  include_context "statement"

  it "should be valid" do
    local_object = RailsXapi::Object.new({
      objectType: "Activity",
      id: "substatement-activity",
      definition: {
        name: {
          "en-US" => "Definition name"
        },
        description: {
          "en-US" => "A simple Experience API statement. Note that the LRS does not need to have any prior information about the Actor (learner), the verb, or the Activity/object."
        }
      }
    })

    statement = RailsXapi::Statement.new({
      verb: @verb,
      object: local_object,
      actor: @actor
    })

    expect(statement.valid?).to be_truthy
    expect(statement.object.definition.as_json).to eq({
      name: {
        "en-US" => "Definition name"
      }.to_json,
      description: {
        "en-US" => "A simple Experience API statement. Note that the LRS does not need to have any prior information about the Actor (learner), the verb, or the Activity/object."
      }.to_json,
      type: nil
    })
  end

  it "should raise an exception" do
    local_object = RailsXapi::Object.new({
      objectType: "Activity",
      id: "substatement-activity",
      definition: {
        name: {
          "en-US" => "Definition name"
        },
        # Add a description missing a language map.
        description: "A simple Experience API statement. Note that the LRS
          does not need to have any prior information about the Actor (learner), the
          verb, or the Activity/object."
      }
    })

    statement = {
      verb: @verb,
      object: local_object,
      actor: @actor
    }

    expect { RailsXapi::Statement.new(statement).valid? }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t("rails_xapi.errors.attribute_must_be_a_valid_language_map", name: "description")
    end
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
