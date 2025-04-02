# spec/models/rails_xapi/context_spec.rb

require "rails_helper"

describe RailsXapi::Context do
  include_context "statement"

  before do
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
      verb: RailsXapi::Verb.new({
        id: RailsXapi::Verb::VERBS_LIST.keys[0]
      }),
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
