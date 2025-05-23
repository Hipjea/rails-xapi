# spec/services/rails_xapi/statement_creator_spec.rb

require "rails_helper"

RSpec.describe RailsXapi::StatementCreator, type: :service do
  before :all do
    @actor = {
      name: "Actor 1",
      mbox_sha1sum: "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f52",
      openid: "http://example.com/object/Actor#1"
    }

    @statement = {
      verb: {
        id: RailsXapi::Verb::VERBS_LIST.keys[0]
      },
      object: {
        id: "/object/1"
      }
    }
  end

  describe "statement creator" do
    it "should create a statement with an actor merged into the data parameter" do
      result =
        RailsXapi::StatementCreator.create(@statement.merge(actor: @actor))
      status, statement = result.values_at(:status, :statement)

      expect(status).to eq(200)
      expect(statement.is_a?(RailsXapi::Statement)).to be_truthy
      expect { statement.as_json }.not_to raise_error
    end

    it "should create a statement with an actor parameter" do
      result = RailsXapi::StatementCreator.create(@statement, @actor)
      status, statement = result.values_at(:status, :statement)

      expect(status).to eq(200)
      expect(statement.is_a?(RailsXapi::Statement)).to be_truthy
      expect { statement.as_json }.not_to raise_error
    end

    it "should create a statement through an asynchronous call to the service" do
      expect {
        RailsXapi::StatementCreator.create(@statement, @actor, { async: true })
      }.to change { RailsXapi::Statement.count }.by(1)
    end

    it "should create a statement with a given @actor instance variable" do
      result = RailsXapi::StatementCreator.create(@statement, @actor)
      status, statement = result.values_at(:status, :statement)

      expect(status).to eq(200)
      expect(statement.is_a?(RailsXapi::Statement)).to be_truthy
      expect { statement.as_json }.not_to raise_error
      expect(statement.actor).to_not be_nil
    end

    it "should set a timestamp when omitted" do
      result =
        RailsXapi::StatementCreator.create(@statement.merge(actor: @actor))
      status, statement = result.values_at(:status, :statement)

      expect(status).to eq(200)
      expect(statement).to_not be_nil
    end

    it "should accept a timestamp value when given" do
      current_time = Time.zone.now - 2.hours
      result =
        RailsXapi::StatementCreator.create(
          @statement.merge(actor: @actor, timestamp: current_time)
        )
      status, statement = result.values_at(:status, :statement)

      expect(status).to eq(200)
      expect(statement.timestamp.to_i).to eq(current_time.to_i)
    end
  end

  describe "complex statements" do
    it "should create a complex xAPI statement" do
      # Save the statement to be able to get its ID within "context".
      result =
        RailsXapi::StatementCreator.create(@statement.merge(actor: @actor))
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
              "en-GB" =>
                "An example meeting that happened on a specific occasion with certain people present.",
              "en-US" =>
                "An example meeting that happened on a specific occasion with certain people present.",
              "fr-FR" =>
                "Une réunion qui a eu lieu avec certaines personnes lors d'une occasion spéciale."
            },
            type: "http://adlnet.gov/expapi/activities/meeting",
            moreInfo: "http://virtualmeeting.example.com/345256"
          },
          objectType: "Activity"
        },
        result: {
          score: {
            raw: 2.5,
            min: 2,
            max: 10,
            scaled: -0.9
          },
          completion: true
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
                    "en-US" =>
                      "A category of meeting used for regular team meetings."
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

      result = RailsXapi::StatementCreator.create(statement_hash)
      status, statement = result.values_at(:status, :statement)

      expect(status).to eq(200)
      # Class checking.
      expect(statement.is_a?(RailsXapi::Statement)).to be_truthy
      expect(statement.actor.is_a?(RailsXapi::Actor)).to be_truthy
      expect(statement.actor.account.is_a?(RailsXapi::Account)).to be_truthy
      expect(statement.verb.is_a?(RailsXapi::Verb)).to be_truthy
      expect(statement.object.is_a?(RailsXapi::Object)).to be_truthy
      expect(
        statement.object.definition.is_a?(RailsXapi::ActivityDefinition)
      ).to be_truthy
      expect(
        statement.object.definition.extensions.first.is_a?(RailsXapi::Extension)
      ).to be_truthy
      expect(statement.result.is_a?(RailsXapi::Result)).to be_truthy
      expect(statement.context.is_a?(RailsXapi::Context)).to be_truthy
      expect(
        statement.object.definition.is_a?(RailsXapi::ActivityDefinition)
      ).to be_truthy
      expect(statement.object.definition.extensions).to all(
        be_a(RailsXapi::Extension)
      )
    end

    def build_interaction_statement(
      interaction_type:,
      component_key:,
      components:,
      correct_pattern:
    )
      {
        actor: {
          name: "Jean Valjean",
          mbox_sha1sum: "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f57"
        },
        verb: {
          id: "http://adlnet.gov/expapi/verbs/attended",
          display: {
            "en-GB" => "attended"
          }
        },
        object: {
          id: "http://www.example.com/meetings/occurances/#{rand(99_999)}",
          definition: {
            :name => {
              "en-GB" => "example #{interaction_type} activity"
            },
            :description => {
              "en-GB" => "An example #{interaction_type} interaction activity."
            },
            :type => "http://adlnet.gov/expapi/activities/cmi.interaction",
            :interactionType => interaction_type,
            :correctResponsesPattern => correct_pattern,
            component_key => components
          },
          objectType: "Activity"
        }
      }
    end

    it "creates a scale interaction activity" do
      statement_hash =
        build_interaction_statement(
          interaction_type: "likert",
          component_key: "scale",
          components: [
            {
              id: "likert_0",
              description: {
                "en-US": "It's OK",
                fr: "C'est ok"
              }
            },
            { id: "likert_1", description: { "en-US": "It's Pretty Cool" } },
            { id: "likert_2", description: { "en-US": "It's Damn Cool" } },
            {
              id: "likert_3",
              description: {
                "en-US": "It's Gonna Change the World"
              }
            }
          ],
          correct_pattern: ["likert_3"]
        )

      result = RailsXapi::StatementCreator.create(statement_hash)
      interaction_activity =
        result[:statement].object.definition.interaction_activity
      expect(result[:status]).to eq(200)
      expect(interaction_activity.interaction_type).to eq("likert")
    end

    it "creates a choice interaction activity" do
      statement_hash =
        build_interaction_statement(
          interaction_type: "choice",
          component_key: "choices",
          components: [
            { id: "tim", description: { "en-US": "Tim" } },
            { id: "ben", description: { "en-US": "Ben" } },
            { id: "ells", description: { "en-US": "Ells" } },
            { id: "mike", description: { "en-US": "Mike" } }
          ],
          correct_pattern: ["tim[,]mike[,]ells[,]ben"]
        )

      result = RailsXapi::StatementCreator.create(statement_hash)
      interaction_activity =
        result[:statement].object.definition.interaction_activity
      expect(result[:status]).to eq(200)
      expect(interaction_activity.interaction_type).to eq("choice")
    end
  end
end
