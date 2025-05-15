# spec/models/rails_xapi/context_spec.rb

require "rails_helper"

describe RailsXapi::Context do
  include_context "statement"

  before :each do
    @actor = {
      name: "Actor 1",
      mbox_sha1sum: "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f52",
      openid: "http://example.com/object/Actor#1"
    }

    @team = {
      name: "Team PB",
      mbox: "mailto:teampb@example.com",
      objectType: "Group"
    }

    @object = RailsXapi::Object.new(id: "/statement-ref-object/1")

    @statement = RailsXapi::Statement.new(@default_statement)
    @statement.save!

    @context_activities = {
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
    }
  end

  it "should be a valid as_json" do
    context = RailsXapi::Context.new(
      contextActivities: @context_activities,
      statement: {
        objectType: "StatementRef",
        id: @statement.id
      }
    )

    statement = RailsXapi::Statement.new(@default_statement.merge(context: context))

    expect(statement.context.as_json).to eq({
      contextActivities: [
        {
          id: "http://www.example.com/meetings/series/1",
          objectType: "parent"
        },
        {
          id: "http://www.example.com/meetings/series/2",
          objectType: "parent"
        },
        {
          definition: {
            description: "{\"en-US\":\"A category of meeting used for regular team meetings.\"}",
            name: "{\"en-US\":\"team meeting\"}",
            type: "http://example.com/expapi/activities/meetingcategory"
          },
          id: "http://www.example.com/meetings/categories/teammeeting",
          objectType: "category"
        }
      ]
    })

    expect(statement.context[:statement_ref]).to eq(@statement.id)
    expect(statement.context.statement).to eq(statement)
  end

  it "should create an instructor" do
    context = RailsXapi::Context.new(instructor: @actor)

    expect(context.instructor.class).to eq(RailsXapi::Actor)
  end

  it "should create a team" do
    context = RailsXapi::Context.new(team: @team)

    expect(context.team.class).to eq(RailsXapi::Actor)
    expect(context.team.object_type).to eq("Group")
  end

  it "should create an instructor and a team" do
    context = RailsXapi::Context.new(instructor: @actor, team: @team)

    expect(context.instructor.class).to eq(RailsXapi::Actor)
    expect(context.team.class).to eq(RailsXapi::Actor)
    expect(context.team.object_type).to eq("Group")
  end

  it "should link to a statement" do
    context = RailsXapi::Context.new(statement: {
      objectType: "StatementRef",
      id: @statement.id
    })

    new_statement = RailsXapi::Statement.new(@default_statement.merge(context: context))

    expect(new_statement.context[:statement_ref]).to eq(@statement.id)
    expect(new_statement.context.statement).to eq(new_statement)
  end

  it "should create context activities" do
    context = RailsXapi::Context.new(
      contextActivities: @context_activities,
      statement: {
        objectType: "StatementRef",
        id: @statement.id
      }
    )

    new_statement = RailsXapi::Statement.new(@default_statement.merge(context: context))
    new_statement.save!

    expect(new_statement.valid?).to be_truthy
    expect(new_statement.context.context_activities).to_not be_empty
    new_statement.context.context_activities.each do |ca|
      expect(ca.object).to_not be_nil if ca.object.object_type == "Activity"
      expect(ca.object.definition).to_not be_nil if ca.activity_type == "category"
    end
  end

  it "should update the object when the context activity already exists" do
    context = RailsXapi::Context.new(
      contextActivities: @context_activities,
      statement: {
        objectType: "StatementRef",
        id: @statement.id
      }
    )

    new_statement = RailsXapi::Statement.new(@default_statement.merge(context: context))
    new_statement.save!

    expect(new_statement.valid?).to be_truthy

    context_activity_object_id = "http://www.example.com/meetings/categories/teammeeting"
    context = RailsXapi::Context.new(
      contextActivities: {
        category: [
          {
            id: context_activity_object_id,
            objectType: "Activity",
            definition: {
              name: {
                "en-US" => "team meeting updated"
              },
              description: {
                "en-US" => "A category of meeting used for regular team meetings."
              },
              type: "http://example.com/expapi/activities/meetingcategory/updated"
            }
          }
        ]
      },
      statement: {
        objectType: "StatementRef",
        id: @statement.id
      }
    )

    updated_statement = RailsXapi::Statement.new(@default_statement.merge(context: context))
    updated_statement.save!

    expect(updated_statement.valid?).to be_truthy
    updated_statement.context.context_activities.each do |ca|
      if ca.object_id == context_activity_object_id
        expect(ca.object.definition.name).to eq({"en-US" => "team meeting updated"}.to_json)
        expect(ca.object.definition.activity_type).to eq("http://example.com/expapi/activities/meetingcategory/updated")
      end
    end
  end

  it "should create a context activity with extensions" do
    context = RailsXapi::Context.new(
      contextActivities: {
        parent: [
          {
            id: "http://www.example.com/meetings/series/1",
            objectType: "Activity"
          }
        ]
      },
      extensions: {
        "http://example.com/profiles/meetings/activitydefinitionextensions/room": {
          name: "Kilby",
          id: "http://example.com/rooms/342"
        }
      },
      statement: {
        objectType: "StatementRef",
        id: @statement.id
      }
    )

    statement = RailsXapi::Statement.new(@default_statement.merge(context: context))
    statement.save!

    expect(statement.valid?).to be_truthy
    expect(statement.context.extensions).to_not be_empty
  end

  it "should not accept a context extension that isn't a hash" do
    context = {
      contextActivities: {
        parent: [
          {
            id: "http://www.example.com/meetings/series/1",
            objectType: "Activity"
          }
        ]
      },
      extensions: "http://example.com/profiles/meetings/activitydefinitionextensions/room",
      statement: {
        objectType: "StatementRef",
        id: @statement.id
      }
    }

    expect { RailsXapi::Context.new(context) }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t("rails_xapi.errors.attribute_must_be_a_hash", name: "extensions")
    end
  end

  it "should set platform property if statement object is Activity" do
    context = RailsXapi::Context.new(
      statement: {
        objectType: "StatementRef",
        id: @statement.id
      },
      platform: "platform-placeholder"
    )

    expect(context.platform).to_not be_nil
  end

  it "should not set platform property if statement object is not Activity" do
    statement_struct = {
      actor: RailsXapi::Actor.new(@actor),
      verb: @verb,
      object: RailsXapi::Object.new({
        objectType: "StatementRef",
        id: "9e13cefd-53d3-4eac-b5ed-2cf6693903bb"
      }),
      context: RailsXapi::Context.new(
        statement: {
          objectType: "StatementRef",
          id: @statement.id
        },
        platform: "platform-placeholder"
      )
    }

    statement = RailsXapi::Statement.new(statement_struct)
    statement.save!

    expect(statement.context.platform).to be_nil
  end
end

# == Schema Information
#
# Table name: rails_xapi_contexts
#
#  id            :integer          not null, primary key
#  language      :string
#  platform      :string
#  registration  :string
#  revision      :string
#  statement_ref :bigint
#  instructor_id :bigint
#  statement_id  :bigint           not null
#  team_id       :bigint
#
# Indexes
#
#  index_rails_xapi_contexts_on_instructor_id  (instructor_id)
#  index_rails_xapi_contexts_on_statement_id   (statement_id)
#  index_rails_xapi_contexts_on_statement_ref  (statement_ref)
#  index_rails_xapi_contexts_on_team_id        (team_id)
#
