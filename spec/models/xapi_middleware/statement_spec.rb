# spec/models/statement_spec.rb

require "rails_helper"

RSpec.describe XapiMiddleware::Statement, type: :model do
  describe "validations" do
    before :all do
      XapiMiddleware::Statement.delete_all
      XapiMiddleware::Actor.delete_all
      XapiMiddleware::Verb.delete_all
      XapiMiddleware::Object.delete_all

      @verb = XapiMiddleware::Verb.new(id: XapiMiddleware::Verb::VERBS_LIST.keys[0])

      @actor = XapiMiddleware::Actor.new(
        name: "Actor 1",
        mbox_sha1sum: "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f52",
        openid: "http://example.com/object/Actor#1"
      )

      @account = XapiMiddleware::Account.new(
        name: "Actor#1",
        homePage: "http://example.com/actor1"
      )

      @object = XapiMiddleware::Object.new(id: "/object/1")

      # Create a statement with an Activity object (by default)
      @default_statement = {
        verb: @verb,
        object: @object,
        actor: @actor
      }

      # Create a statement with a SubStatement object
      @substatement_statement = {
        verb: @verb,
        object: XapiMiddleware::Object.new(
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
      default_statement = XapiMiddleware::Statement.new(@default_statement)
      substatement_statement = XapiMiddleware::Statement.new(@substatement_statement)

      expect(default_statement).to be_valid
      expect(substatement_statement).to be_valid
    end

    it "should raise an error for a statement missing object id" do
      statement = XapiMiddleware::Statement.new(
        verb: @verb,
        object: XapiMiddleware::Object.new(id: nil),
        actor: @actor
      )

      expect { statement.save! }.to raise_error do |error|
        expect(error).to be_a(ActiveRecord::RecordInvalid)
      end
    end

    it "should raise an error for a statement having an invalid object type" do
      invalid_object = XapiMiddleware::Object.new(id: "/object/1", objectType: "Rogue")
      statement = XapiMiddleware::Statement.new(
        verb: @verb,
        object: invalid_object,
        actor: @actor
      )

      expect { statement.save! }.to raise_error do |error|
        expect(error).to be_a(ActiveRecord::RecordInvalid)
      end
    end

    it "should raise an error for a statement with a SubStatement object missing the actor" do
      statement_invalid_object_substatement = XapiMiddleware::Statement.new(
        verb: @verb,
        object: XapiMiddleware::Object.new(
          objectType: "SubStatement",
          verb: @verb,
          object: XapiMiddleware::Object.new(
            objectType: "StatementRef",
            id: "e05aa883-acaf-40ad-bf54-02c8ce485fb0"
          )
        ),
        actor: @actor
      )

      expect { statement_invalid_object_substatement.save! }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.missing_actor")
      end
    end

    it "should raise an error for a statement missing the actor inverse functional identifier (IFI)" do
      statement = XapiMiddleware::Statement.new(
        verb: @verb,
        object: @object,
        actor: XapiMiddleware::Actor.new(mbox: nil, mbox_sha1sum: nil, account: nil, openid: nil)
      )

      expect { statement.save! }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.actor_ifi_must_be_present")
      end
    end

    it "should raise an error for a statement with a malformed mbox value" do
      mbox = "mailto:admin@example.c"
      statement = XapiMiddleware::Statement.new(
        verb: @verb,
        object: @object,
        actor: XapiMiddleware::Actor.new(mbox: mbox)
      )

      expect { statement.save! }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.malformed_mbox", name: mbox)
      end
    end

    it "should raise an error for a statement with an invalid mbox_sha1sum value" do
      mbox_sha1sum = "sha1:d35132bd0bfc15ada6f5229002b5288d94a46"
      statement = XapiMiddleware::Statement.new(
        verb: @verb,
        object: @object,
        actor: XapiMiddleware::Actor.new(mbox_sha1sum: mbox_sha1sum)
      )

      expect { statement.save! }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.malformed_mbox_sha1sum")
      end
    end

    it "should raise an error for a statement with an invalid actor object type" do
      actor = XapiMiddleware::Actor.new(
        name: "Actor 1",
        openid: "http://example.com/object/Actor#1",
        objectType: "Rogue"
      )
      statement = XapiMiddleware::Statement.new(
        verb: @verb,
        object: @object,
        actor: actor
      )

      expect { statement.save! }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.invalid_actor_object_type", name: actor.object_type)
      end
    end

    it "should raise an error for a statement with an actor having a malformed openID URI" do
      actor = XapiMiddleware::Actor.new(
        name: "Actor 1",
        openid: "htt://example/object/Actor#1"
      )
      statement = XapiMiddleware::Statement.new(
        verb: @verb,
        object: @object,
        actor: actor
      )

      expect { statement.save! }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.malformed_openid_uri", uri: actor.openid)
      end
    end
  end
end

# == Schema Information
#
# Table name: xapi_middleware_statements
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
#  index_xapi_middleware_statements_on_actor_id   (actor_id)
#  index_xapi_middleware_statements_on_object_id  (object_id)
#  index_xapi_middleware_statements_on_verb_id    (verb_id)
#
