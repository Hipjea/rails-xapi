# spec/models/rails_xapi/object_spec.rb

require "rails_helper"

describe RailsXapi::Object do
  let(:base_object) { build(:object) }
  let(:substatement_object) { build(:object, :substatement) }
  let(:invalid_object) { build(:object, :invalid_object_type) }
  let(:object_with_activity_definition) { build(:object, :with_activity_definition) }
  let(:object_with_invalid_activity_definition) { build(:object, :with_invalid_activity_definition) }

  it "should be valid" do
    expect(base_object.valid?).to be_truthy
  end

  it "should create a substatement" do
    expect(substatement_object.object_type).to eq("SubStatement")
    expect(substatement_object.valid?).to be_truthy
    expect(substatement_object.statement).to_not be_nil
  end

  it "should not accept an invalid objectType" do
    expect(invalid_object.valid?).to be_falsy
  end

  it "should not be valid with a missing substatement agent" do
    object = RailsXapi::Object.new(
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

  it "should create an object with a definition" do
    expect(object_with_activity_definition.valid?).to be_truthy
  end

  it "should update an object definition" do
    object_with_activity_definition.save!
    object_with_activity_definition.update_definition({
      name: {"en" => "object updated definition"},
      description: {"en" => "Object updated definition"},
      type: "Activity"
    })

    expect(object_with_activity_definition.valid?).to be_truthy
    expect(object_with_activity_definition.definition.name).to eq("{\"en\":\"object updated definition\"}")
  end

  it "should raise an error with incorrect extensions" do
    expect { RailsXapi::Object.new(object_with_invalid_activity_definition.attributes) }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t("rails_xapi.errors.attribute_must_be_a_hash", name: "extensions")
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
