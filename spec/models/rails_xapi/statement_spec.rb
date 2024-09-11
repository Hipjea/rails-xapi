# spec/models/rails_xapi/statement_spec.rb

require "rails_helper"

RSpec.describe RailsXapi::Statement, type: :model do
  include_context "statement"

  describe "validations" do
    before :all do
      RailsXapi::Statement.delete_all
      RailsXapi::Actor.delete_all
      RailsXapi::Verb.delete_all
      RailsXapi::Object.delete_all

      @account = RailsXapi::Account.new(
        name: "Actor#1",
        homePage: "http://example.com/actor1"
      )

      # Create a statement with a SubStatement object
      @substatement_statement = {
        verb: @verb,
        object: RailsXapi::Object.new(
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
        ),
        actor: @actor
      }
    end

    it "should be valid" do
      default_statement = RailsXapi::Statement.new(@default_statement)
      substatement_statement = RailsXapi::Statement.new(@substatement_statement)

      expect(default_statement).to be_valid
      expect(substatement_statement).to be_valid
    end

    it "should raise an error for a statement missing object id" do
      statement = RailsXapi::Statement.new(
        verb: @verb,
        object: RailsXapi::Object.new(id: nil),
        actor: @actor
      )

      expect { statement.save! }.to raise_error do |error|
        expect(error).to be_a(ActiveRecord::RecordInvalid)
      end
    end

    it "should raise an error for a statement having an invalid object type" do
      invalid_object = RailsXapi::Object.new(id: "/object/1", objectType: "Rogue")
      statement = RailsXapi::Statement.new(
        verb: @verb,
        object: invalid_object,
        actor: @actor
      )

      expect { statement.save! }.to raise_error do |error|
        expect(error).to be_a(ActiveRecord::RecordInvalid)
      end
    end

    it "should raise an error for a statement with a SubStatement object missing the actor" do
      statement_invalid_object_substatement = RailsXapi::Statement.new(
        verb: @verb,
        object: RailsXapi::Object.new(
          objectType: "SubStatement",
          verb: @verb,
          object: RailsXapi::Object.new(
            objectType: "StatementRef",
            id: "e05aa883-acaf-40ad-bf54-02c8ce485fb0"
          )
        ),
        actor: @actor
      )

      expect { statement_invalid_object_substatement.save! }.to raise_error do |error|
        expect(error).to be_a(RailsXapi::Errors::XapiError)
        expect(error.message).to eq I18n.t("rails_xapi.errors.missing_actor")
      end
    end

    it "should raise an error for a statement missing the actor inverse functional identifier (IFI)" do
      statement = RailsXapi::Statement.new(
        verb: @verb,
        object: @object,
        actor: RailsXapi::Actor.new(mbox: nil, mbox_sha1sum: nil, account: nil, openid: nil)
      )

      expect { statement.save! }.to raise_error do |error|
        expect(error).to be_a(RailsXapi::Errors::XapiError)
        expect(error.message).to eq I18n.t("rails_xapi.errors.actor_ifi_must_be_present")
      end
    end

    it "should raise an error for a statement with a malformed mbox value" do
      mbox = "mailto:admin@example.c"
      statement = RailsXapi::Statement.new(
        verb: @verb,
        object: @object,
        actor: RailsXapi::Actor.new(mbox: mbox)
      )

      expect { statement.save! }.to raise_error do |error|
        expect(error).to be_a(RailsXapi::Errors::XapiError)
        expect(error.message).to eq I18n.t("rails_xapi.errors.malformed_mbox", name: mbox)
      end
    end

    it "should raise an error for a statement with an invalid mbox_sha1sum value" do
      mbox_sha1sum = "sha1:d35132bd0bfc15ada6f5229002b5288d94a46"
      statement = RailsXapi::Statement.new(
        verb: @verb,
        object: @object,
        actor: RailsXapi::Actor.new(mbox_sha1sum: mbox_sha1sum)
      )

      expect { statement.save! }.to raise_error do |error|
        expect(error).to be_a(RailsXapi::Errors::XapiError)
        expect(error.message).to eq I18n.t("rails_xapi.errors.malformed_mbox_sha1sum")
      end
    end

    it "should raise an error for a statement with an invalid actor object type" do
      actor = RailsXapi::Actor.new(
        name: "Actor 1",
        openid: "http://example.com/object/Actor#1",
        objectType: "Rogue"
      )
      statement = RailsXapi::Statement.new(
        verb: @verb,
        object: @object,
        actor: actor
      )

      expect { statement.save! }.to raise_error do |error|
        expect(error).to be_a(RailsXapi::Errors::XapiError)
        expect(error.message).to eq I18n.t("rails_xapi.errors.invalid_actor_object_type", name: actor.object_type)
      end
    end

    it "should raise an error for a statement with an actor having a malformed openID URI" do
      actor = RailsXapi::Actor.new(
        name: "Actor 1",
        openid: "htt://example/object/Actor#1"
      )
      statement = RailsXapi::Statement.new(
        verb: @verb,
        object: @object,
        actor: actor
      )

      expect { statement.save! }.to raise_error do |error|
        expect(error).to be_a(RailsXapi::Errors::XapiError)
        expect(error.message).to eq I18n.t("rails_xapi.errors.malformed_openid_uri", uri: actor.openid)
      end
    end

    it "should be a valid statement with a context" do
      context = RailsXapi::Context.new(
        contextActivities: {
          parent: [
            {
              id: "http://www.example.com/meetings/series/267",
              objectType: "Activity"
            }
          ],
          category: [
            {
              id: "http://www.example.com/meetings/categories/teammeeting",
              objectType: "Activity",
              definition: {
                name: {
                  "en" => "team meeting"
                },
                description: {
                  "en" => "A category of meeting used for regular team meetings."
                },
                type: "http://example.com/expapi/activities/meetingcategory"
              }
            }
          ],
          other: [
            {
              id: "http://www.example.com/meetings/occurances/34257",
              objectType: "Activity"
            },
            {
              id: "http://www.example.com/meetings/occurances/3425567",
              objectType: "Activity"
            }
          ]
        }
      )

      statement = RailsXapi::Statement.new(@default_statement.merge(context: context))

      expect(statement.valid?).to be_truthy
    end
  end
end

# == Schema Information
#
# Table name: rails_xapi_statements
#
#  id         :integer          not null, primary key
#  timestamp  :datetime
#  created_at :datetime         not null
#  actor_id   :string           not null
#  object_id  :string           not null
#  verb_id    :string           not null
#
# Indexes
#
#  index_rails_xapi_statements_on_actor_id   (actor_id)
#  index_rails_xapi_statements_on_object_id  (object_id)
#  index_rails_xapi_statements_on_verb_id    (verb_id)
#
