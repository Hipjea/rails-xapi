# spec/models/statement_spec.rb

require "rails_helper"

RSpec.describe XapiMiddleware::Statement, type: :model do
  describe "validations" do
    before :all do
      # Create a statement with an Activity object (by default)
      @default_statement = {
        verb: {
          id: "http://example.com/verb"
        },
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
          score_max: 100
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
          score_max: 100
        }
      }

      # Create an invalid statement missing object id.
      @invalid_statement = {
        verb: {
          id: "http://example.com/verb"
        },
        object: {
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
          score_max: 100
        }
      }
    end

    it "should be valid" do
      default_statement = XapiMiddleware::Statement.new(@default_statement)
      substatement_statement = XapiMiddleware::Statement.new(@substatement_statement)

      expect(default_statement).to be_valid
      expect(substatement_statement).to be_valid
    end

    it "should raise an error" do
      expect { XapiMiddleware::Statement.new(@invalid_statement) }.to raise_error do |error|
        expect(error).to be_a(XapiMiddleware::Errors::XapiError)
        expect(error.message).to eq "missing object keys: id"
      end
    end
  end
end
