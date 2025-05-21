# spec/models/rails_xapi/object_spec.rb

require "rails_helper"

describe RailsXapi::Object do
  let(:base_object) { build(:object) }
  let(:substatement_object) { build(:object, :substatement) }
  let(:invalid_object) { build(:object, object_type: "InvalidType") }
  let(:object_with_activity_definition) do
    build(:object, :with_activity_definition)
  end
  let(:object_with_invalid_activity_definition) do
    build(:object, :with_invalid_activity_definition)
  end

  it "is valid" do
    expect(base_object).to be_valid
  end

  it "creates a substatement" do
    expect(substatement_object.object_type).to eq("SubStatement")
    expect(substatement_object).to be_valid
    expect(substatement_object.statement).not_to be_nil
    expect(substatement_object.activity?).to be_falsy
  end

  it "is not valid with an invalid object_type" do
    expect(invalid_object).not_to be_valid
    expect(invalid_object.errors[:object_type]).to include(
      "is not included in the list"
    )
  end

  it "is not valid with a missing substatement agent" do
    object =
      described_class.new(
        objectType: "SubStatement",
        verb: {
          id: "http://adlnet.gov/expapi/verbs/voided",
          display: {
            "en-US" => "voided"
          }
        },
        object: {
          objectType: "Activity",
          id: "substatement-activity"
        }
      )

    expect { object.save! }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t("rails_xapi.errors.missing_actor")
    end
  end

  it "creates an object with a definition" do
    expect(object_with_activity_definition).to be_valid
  end

  it "updates an object definition" do
    object_with_activity_definition.save!
    object_with_activity_definition.update_definition(
      {
        name: {
          "en" => "object updated definition"
        },
        description: {
          "en" => "Object updated definition"
        },
        type: "http://adlnet.gov/expapi/activities/cmi.interaction"
      }
    )

    expect(object_with_activity_definition).to be_valid
    expect(object_with_activity_definition.definition.name).to eq(
      "{\"en\":\"object updated definition\"}"
    )
  end

  it "raises an error with incorrect extensions" do
    expect {
      described_class.new(object_with_invalid_activity_definition.attributes)
    }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t(
           "rails_xapi.errors.attribute_must_be_a_hash",
           name: "extensions"
         )
    end
  end
end

# == Schema Information
#
# Table name: rails_xapi_objects
#
#  id           :string           not null, primary key
#  object_type  :string           not null
#  statement_id :bigint
#
# Indexes
#
#  index_rails_xapi_objects_on_id            (id) UNIQUE
#  index_rails_xapi_objects_on_statement_id  (statement_id)
#
