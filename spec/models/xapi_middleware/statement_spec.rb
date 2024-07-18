# spec/models/statement_spec.rb

require "rails_helper"

RSpec.describe XapiMiddleware::Statement, type: :model do
  describe "validations" do
    before :all do
      # Create a statement with an Activity object (by default)
      @default_statement = {
        verb: { id: "http://example.com/verb" },
        object: {
          id: "http://example.com/object",
          definition: {
            type: "http://adlnet.gov/expapi/activities/course",
          }
        },
        actor: {
          name: "Actor 1",
          mbox_sha1sum: "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f52",
          account: {
            name: "Actor#1"
          },
          openid: "http://example.com/object/Actor#1" 
        },
        result: { 
          response: "The actor 1 answered",
          success: true,
          score_raw: 50,
          score_min: 0,
          score_max: 100,
          duration: "PT4H35M59.14S",
          extensions: {
            "http://example.com/extension/1": "empty",
            "http://example.com/extension/2": "also empty"
          }
        }
      }

      # Create a statement with a SubStatement object
      @substatement_statement = {
        verb: {
          id: "http://example.com/verb",
          display: {
            "en-US": "voided",
            fr: "vidé",
            "gb": "voided"
          }
        },
        object: {
          objectType: "SubStatement",
          actor: {
            objectType: "Agent",
            name: "Example Admin",
            mbox: "mailto:admin@example.com"
          },
          verb: {
            id: "http://adlnet.gov/expapi/verbs/voided",
            display: {
              "en-US": "voided"
            }
          },
          object: {
            objectType: "StatementRef",
            id: "e05aa883-acaf-40ad-bf54-02c8ce485fb0"
          }
        },
        actor: {
          name: "ÿøhnNÿ DœE",
          mbox: "mailto:yohnny.doe@localhost.com",
          account: {
            name: "JohnnyAccount#1"
          },
          openid: "http://example.com/object/JohnnyAccount#1" 
        },
        result: { 
          response: "The user answered",
          success: true,
          score_raw: 50,
          score_min: 0,
          score_max: 100,
          duration: "PT4H35M59.14S",
          completion: true
        }
      }

      # An invalid statement missing object id.
      @statement_missing_object_id = @default_statement.merge(object: {id: nil})

      # An invalid statement having an invalid object type
      @statement_invalid_object_object_type = @default_statement.merge(object: {id: "http://example.com/object", objectType: "Rogue"})

      # An invalid statement with a SubStatement object missing the actor
      @statement_invalid_object_substatement = {
        verb: { id: "http://example.com/verb" },
        object: {
          objectType: "SubStatement",
          verb: {
            id: "http://adlnet.gov/expapi/verbs/voided",
            display: {
              "en-US": "voided"
            }
          },
          object: {
            objectType: "StatementRef",
            id: "e05aa883-acaf-40ad-bf54-02c8ce485fb0"
          }
        },
        actor: {
          name: "Actor's name",
          openid: "http://example.com/object/JohnnyAccount#1" 
        }
      }

      # An invalid statement missing the actor inverse functional identifier (IFI)
      @statement_missing_actor_ifi = @default_statement.merge(actor: {mbox: nil, mbox_sha1sum: nil, account: {}, openid: nil})

      # An invalid statement with a malformed actor mbox value
      @statement_malformed_mbox_value = @default_statement.merge(actor: {mbox: "mailto:admin@example.c"})

      # An invalid statement with a malformed actor mbox_sha1sum value
      @statement_malformed_mbox_sha1sum_value = @default_statement.merge(actor: {mbox_sha1sum: "sha1:d35132bd0bfc15ada6f5229002b5288d94a46"})

      # An invalid statement with an invalid actor object type
      @statement_invalid_actor_object_type = @default_statement.merge(actor: {objectType: "Rogue"})

      # An invalid statement with a malformed openID URI
      @statement_malformed_openid = @default_statement.merge(actor: {openid: "htt://example/object/Actor#1"})

      # An invalid statement with a malformed actor account homePage URL
      @statement_malformed_home_page = @default_statement.merge(actor: {account: {homePage: "htt://example.com/homepage"}})
    end

    it "should be valid" do
      default_statement = XapiMiddleware::Statement.new(@default_statement)
      substatement_statement = XapiMiddleware::Statement.new(@substatement_statement)

      expect(default_statement).to be_valid
      expect(substatement_statement).to be_valid
    end

    it "should raise an error for a statement missing object id" do
      expect { XapiMiddleware::Statement.new(@statement_missing_object_id) }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.missing_object_keys", keys: "id")
      end
    end

    it "should raise an error for a statement having an invalid object type" do
      expect { XapiMiddleware::Statement.new(@statement_invalid_object_object_type) }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.invalid_object_object_type",
          name: @statement_invalid_object_object_type[:object][:objectType])
      end
    end

    it "should raise an error for a statement with a SubStatement object missing the actor" do
      expect { XapiMiddleware::Statement.new(@statement_invalid_object_substatement) }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.invalid_object_substatement")
      end
    end

    it "should raise an error for a statement missing the actor inverse functional identifier (IFI)" do
      expect { XapiMiddleware::Statement.new(@statement_missing_actor_ifi) }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.actor_ifi_must_be_present")
      end
    end

    it "should raise an error for a statement with a malformed mbox value" do
      expect { XapiMiddleware::Statement.new(@statement_malformed_mbox_value) }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.malformed_mbox", name: @statement_malformed_mbox_value[:actor][:mbox])
      end
    end

    it "should raise an error for a statement with an invalid mbox_sha1sum value" do
      expect { XapiMiddleware::Statement.new(@statement_malformed_mbox_sha1sum_value) }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.malformed_mbox_sha1sum")
      end
    end

    it "should raise an error for a statement with an invalid actor object type" do
      expect { XapiMiddleware::Statement.new(@statement_invalid_actor_object_type) }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.invalid_actor_object_type",
          name: @statement_invalid_actor_object_type[:actor][:objectType])
      end
    end

    it "should raise an error for a statement with an actor having a malformed openID URI" do
      expect { XapiMiddleware::Statement.new(@statement_malformed_openid) }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.malformed_openid_uri",
          uri: @statement_malformed_openid[:actor][:openid])
      end
    end

    it "should raise an error for a statement with an actor having a malformed account homePage URL" do
      expect { XapiMiddleware::Statement.new(@statement_malformed_home_page) }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq I18n.t("xapi_middleware.errors.malformed_account_home_page_url",
          url: @statement_malformed_home_page[:actor][:account][:homePage])
      end
    end
  end
end

# == Schema Information
#
# Table name: xapi_middleware_statements
#
#  id         :integer          not null, primary key
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
