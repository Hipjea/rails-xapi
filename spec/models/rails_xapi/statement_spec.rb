# spec/models/rails_xapi/statement_spec.rb

require "rails_helper"

RSpec.describe RailsXapi::Statement, type: :model do
  describe "validations" do
    before do
      described_class.delete_all
      RailsXapi::Actor.delete_all
      RailsXapi::Verb.delete_all
      RailsXapi::Object.delete_all
    end

    let(:invalid_actor) { build(:actor) }
    let(:actor) { build(:actor, :mbox) }
    let(:verb) { build(:verb) }
    let(:substatement_object) { build(:object, :substatement) }

    it "is valid with default statement and substatement" do
      default_statement = build(:statement)
      substatement_statement =
        build(:statement, verb: verb, object: substatement_object, actor: actor)

      expect(default_statement).to be_valid
      expect(substatement_statement).to be_valid
    end

    it "raises error when object id is missing" do
      statement =
        build(
          :statement,
          verb: verb,
          object: build(:object, id: nil),
          actor: actor
        )

      expect { statement.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "raises error when object type is invalid" do
      statement =
        build(
          :statement,
          verb: verb,
          object: build(:object, id: "/object/1", object_type: "Rogue"),
          actor: actor
        )

      expect { statement.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "raises error when SubStatement object is missing actor" do
      statement = build(:statement, :without_actor)

      expect { statement.save! }.to raise_error(
        ActiveRecord::RecordInvalid
      ) do |error|
        expect(error.record.errors[:actor]).to include("must exist")
      end
    end

    it "raises error when actor IFI is missing" do
      actor_missing_ifi =
        build(:actor, mbox: nil, mbox_sha1sum: nil, account: nil, openid: nil)
      statement = build(:statement, verb: verb, actor: actor_missing_ifi)

      expect { statement.save! }.to raise_error(
        RailsXapi::Errors::XapiError,
        I18n.t("rails_xapi.errors.actor_ifi_must_be_present")
      )
    end

    it "raises error for malformed mbox" do
      malformed_mbox = "mailto:admin@example.c"
      actor_with_bad_mbox = build(:actor, mbox: malformed_mbox)
      statement = build(:statement, verb: verb, actor: actor_with_bad_mbox)

      expect { statement.save! }.to raise_error(
        RailsXapi::Errors::XapiError,
        I18n.t("rails_xapi.errors.malformed_mbox", name: malformed_mbox)
      )
    end

    it "raises error for invalid mbox_sha1sum" do
      invalid_sha1sum = "sha1:d35132bd0bfc15ada6f5229002b5288d94a46"
      actor_with_bad_sha1sum = build(:actor, mbox_sha1sum: invalid_sha1sum)
      statement = build(:statement, verb: verb, actor: actor_with_bad_sha1sum)

      expect { statement.save! }.to raise_error(
        RailsXapi::Errors::XapiError,
        I18n.t("rails_xapi.errors.malformed_mbox_sha1sum")
      )
    end

    it "raises error for invalid actor objectType" do
      rogue_actor =
        build(
          :actor,
          name: "Actor 1",
          openid: "http://example.com/object/Actor#1",
          object_type: "Rogue"
        )
      statement = build(:statement, verb: verb, actor: rogue_actor)

      expect { statement.save! }.to raise_error(
        RailsXapi::Errors::XapiError,
        I18n.t(
          "rails_xapi.errors.invalid_actor_object_type",
          name: rogue_actor.object_type
        )
      )
    end

    it "raises error for malformed openid URI" do
      bad_openid_actor =
        build(:actor, name: "Actor 1", openid: "htt://example/object/Actor#1")
      statement = build(:statement, verb: verb, actor: bad_openid_actor)

      expect { statement.save! }.to raise_error(
        RailsXapi::Errors::XapiError,
        I18n.t(
          "rails_xapi.errors.malformed_openid_uri",
          uri: bad_openid_actor.openid
        )
      )
    end

    it "is valid with a context" do
      context =
        build(
          :context,
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
                    "en" =>
                      "A category of meeting used for regular team meetings."
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

      statement = build(:statement, context: context)

      expect(statement).to be_valid
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
