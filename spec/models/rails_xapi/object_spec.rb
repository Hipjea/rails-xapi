# spec/models/rails_xapi/object_spec.rb

require "rails_helper"

describe RailsXapi::Object do
  before :all do
    @base_object = {id: "/object/1"}

    @substatement_object = {
      objectType: "SubStatement",
      actor: {
        objectType: "Agent",
        name: "Example Admin",
        mbox: "mailto:admin@example.com"
      },
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
    }

    @invalid_object_object_type = {
      id: "/object/1",
      objectType: "Rogue"
    }
  end

  it "should be valid" do
    object = RailsXapi::Object.new(@base_object)

    expect(object.valid?).to be_truthy
  end

  it "should create a substatement" do
    object = RailsXapi::Object.new(@substatement_object)
    object.save

    expect(object.object_type).to eq("SubStatement")
    expect(object.valid?).to be_truthy
    expect(object.statement).to_not be_nil
  end

  it "should not accept an invalid objectType" do
    object = RailsXapi::Object.new(@invalid_object_object_type)

    expect(object.valid?).to be_falsy
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
    object = RailsXapi::Object.new(@base_object.merge(
      definition: {
        name: {"en-US" => "object definition"},
        description: {"en" => "Object definition"},
        type: "Activity",
        extensions: {
          "http://example.com/profiles/meetings/activitydefinitionextensions/room": {
            "name": "Kilby",
            "id": "http://example.com/rooms/342"
          }
        },
        moreInfo: "http://example.com/more_infos"
      }
    ))

    expect(object.valid?).to be_truthy
  end

  it "should update an object definition" do
    object = RailsXapi::Object.new(@base_object.merge(
      definition: {
        name: {"en-US" => "object definition"},
        description: {"en" => "Object definition"},
        type: "Activity"
      }
    ))

    object.save!
    object.update_definition({
      name: {"en" => "object updated definition"},
      description: {"en" => "Object updated definition"},
      type: "Activity"
    })

    expect(object.valid?).to be_truthy
    expect(object.definition.name).to eq("{\"en\":\"object updated definition\"}")
  end

  it "should raise an error with incorrect extensions" do
    object = @base_object.merge(
      definition: {
        name: {"en-US" => "object definition"},
        extensions: "http://example.com/profiles/meetings/activitydefinitionextensions/room",
      }
    )

    expect { RailsXapi::Object.new(object) }.to raise_error do |error|
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
