require "rails_helper"

RSpec.describe RailsXapi::StatementCreator, type: :service do
  before :all do
    @actor = {
      name: "Actor 1",
      mbox_sha1sum: "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f52",
      openid: "http://example.com/object/Actor#1"
    }

    @statement = {
      verb: {id: RailsXapi::Verb::VERBS_LIST.keys[0]},
      object: {id: "/object/1"}
    }
  end

  describe "statement creator calls" do
    it "should create a statement through a call to the statement creator service" do
      statement_creator = RailsXapi::StatementCreator.new(@statement.merge(actor: @actor))
      result = statement_creator.call
      status, statement = result.values_at(:status, :statement)

      expect(status).to eq(200)
      expect(statement.is_a?(RailsXapi::Statement)).to be_truthy
      expect { statement.as_json }.not_to raise_error
    end

    it "should create a statement through an asynchronous call to the statement creator service" do
      statement_creator = RailsXapi::StatementCreator.new(@statement.merge(actor: @actor))

      expect { statement_creator.call(async: true) }.to change {
        RailsXapi::Statement.count
      }.by(1)
    end

    it "should create a statement with a given @actor instance variable" do
      statement_creator = RailsXapi::StatementCreator.new(@statement, @actor)
      result = statement_creator.call
      status, statement = result.values_at(:status, :statement)

      expect(status).to eq(200)
      expect(statement.is_a?(RailsXapi::Statement)).to be_truthy
      expect { statement.as_json }.not_to raise_error
      expect(statement.actor).to_not be_nil
    end

    it "should set a timestamp when omitted" do
      statement_creator = RailsXapi::StatementCreator.new(@statement.merge(actor: @actor))
      result = statement_creator.call
      status, statement = result.values_at(:status, :statement)

      expect(status).to eq(200)
      expect(statement).to_not be_nil
    end

    it "should accept a timestamp value when given" do
      current_time = Time.zone.now - 2.hours
      statement_creator = RailsXapi::StatementCreator.new(@statement.merge(actor: @actor, timestamp: current_time))
      result = statement_creator.call
      status, statement = result.values_at(:status, :statement)

      expect(status).to eq(200)
      expect(statement.timestamp.to_i).to eq(current_time.to_i)
    end
  end

  describe "complex statements" do
    it "should create a complex xAPI statement" do
      # Save the statement to be able to get its ID within "context".
      statement_creator = RailsXapi::StatementCreator.new(@statement.merge(actor: @actor))
      result = statement_creator.call
      _, statement_ref = result.values_at(:status, :statement)

      statement_hash = {
        actor: {
          name: "Jean Valjean",
          mbox_sha1sum: "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f57",
          openid: "http://example.com/object/jean_valjean#1",
          account: {
            name: "JeanValjean#1",
            homePage: "http://example.com/actor/jean_valjean1"
          }
        },
        verb: {
          id: "http://adlnet.gov/expapi/verbs/attended",
          display: {
            "en-GB" => "attended",
            "en-US" => "attended",
            "fr-FR" => "assisté"
          }
        },
        object: {
          id: "http://www.example.com/meetings/occurances/34534",
          definition: {
            extensions: {
              "http://example.com/profiles/meetings/activitydefinitionextensions/room": {
                name: "Kilby",
                id: "http://example.com/rooms/342"
              }
            },
            name: {
              "en-GB" => "example meeting",
              "en-US" => "example meeting",
              "fr-FR" => "réunion d'exemple"
            },
            description: {
              "en-GB" => "An example meeting that happened on a specific occasion with certain people present.",
              "en-US" => "An example meeting that happened on a specific occasion with certain people present.",
              "fr-FR" => "Une réunion qui a eu lieu avec certaines personnes lors d'une occasion spéciale."
            },
            type: "http://adlnet.gov/expapi/activities/meeting",
            moreInfo: "http://virtualmeeting.example.com/345256"
          },
          objectType: "Activity"
        },
        context: {
          contextActivities: {
            parent: [
              {
                id: "http://www.example.com/meetings/series/1",
                objectType: "Activity"
              },
              {
                id: "http://www.example.com/meetings/series/2",
                objectType: "Activity"
              }
            ],
            category: [
              {
                id: "http://www.example.com/meetings/categories/teammeeting",
                objectType: "Activity",
                definition: {
                  name: {
                    "en-US" => "team meeting"
                  },
                  description: {
                    "en-US" => "A category of meeting used for regular team meetings."
                  },
                  type: "http://example.com/expapi/activities/meetingcategory"
                }
              }
            ]
          },
          statement: {
            objectType: "StatementRef",
            id: statement_ref.id
          }
        }
      }

      statement_creator = RailsXapi::StatementCreator.new(statement_hash)
      result = statement_creator.call
      status, statement = result.values_at(:status, :statement)

      expect(status).to eq(200)
      # Class checking.
      expect(statement.is_a?(RailsXapi::Statement)).to be_truthy
      expect(statement.actor.is_a?(RailsXapi::Actor)).to be_truthy
      expect(statement.actor.account.is_a?(RailsXapi::Account)).to be_truthy
      expect(statement.verb.is_a?(RailsXapi::Verb)).to be_truthy
      expect(statement.object.is_a?(RailsXapi::Object)).to be_truthy
      expect(statement.object.definition.is_a?(RailsXapi::ActivityDefinition)).to be_truthy
      expect(statement.object.definition.extensions).to all(be_a(RailsXapi::Extension))
    end
  end
end
