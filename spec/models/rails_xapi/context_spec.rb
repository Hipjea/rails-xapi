# spec/models/rails_xapi/context_spec.rb

require "rails_helper"

describe RailsXapi::Context do
<<<<<<< HEAD
  let(:statement) { build(:statement, :with_context) }

  it "is valid as_json" do
    expect(statement.context.as_json).to eq(
      {
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
          ]
        }
      }
    )

    expect(statement.context[:statement_ref]).to eq(statement.id)
    expect(statement.context.statement).to eq(statement)
  end

  it "creates an instructor" do
    context = build(:context, :with_instructor)

    expect(context.instructor).to be_a(RailsXapi::Actor)
  end

  it "creates a team" do
    context = build(:context, :with_team)

    expect(context.team).to be_a(RailsXapi::Actor)
    expect(context.team.object_type).to eq("Group")
  end

  it "creates an instructor and a team" do
    context = build(:context, :with_instructor_and_team)

    expect(context.instructor).to be_a(RailsXapi::Actor)
    expect(context.team).to be_a(RailsXapi::Actor)
    expect(context.team.object_type).to eq("Group")
  end

  it "links to a statement using factories" do
    statement = build(:statement)
    # Build a context with statement reference
    context = build(:context, statement: statement, statement_ref: statement)
    # Assign the context to a new statement
    new_statement =
      build(:statement, statement.attributes.merge(context: context))

    expect(new_statement.context[:statement_ref]).to eq(statement.id)
    expect(new_statement.context.statement).to eq(new_statement)
  end

  it "creates context activities" do
    context_activities = [
      build(:context_activity, :parent_series_1),
      build(:context_activity, :parent_series_2)
    ]
    context = build(:context, context_activities: context_activities)
    new_statement = build(:statement, context: context)
    new_statement.save!

    expect(new_statement).to be_valid
    expect(new_statement.context.context_activities).not_to be_empty

    new_statement.context.context_activities.each do |ca|
      expect(ca.object).not_to be_nil if ca.object.object_type == "Activity"
      if ca.activity_type == "category"
        expect(ca.object.definition).not_to be_nil
=======
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
>>>>>>> 6f951bba9fea07eb45e19bb596af7a54ba23a187
      end
    end
  end

<<<<<<< HEAD
  it "updates the object when the context activity already exists" do
    context_activity_object_id =
      "http://www.example.com/meetings/categories/teammeeting"

    original_object =
      create(
        :object,
        :with_activity_definition,
        id: context_activity_object_id,
        object_type: "Activity"
      )

    # Create context activity and initial context + statement
    context_activity =
      build(
        :context_activity,
        activity_type: "category",
        object: original_object
      )
    context = build(:context, context_activities: [context_activity])
    statement = create(:statement, context: context)

    # Update the definition in place
    definition = original_object.definition
    definition.assign_attributes(
      name: {
        "en-US" => "team meeting updated"
      },
      activity_type:
        "http://example.com/expapi/activities/meetingcategory/updated"
    )
    definition.save!

    # Reload the statement's context activity from DB
    statement.reload
    updated_ca =
      statement.context.context_activities.find do |ca|
        ca.object_id == context_activity_object_id
      end

    # Assert updated values
    expect(updated_ca).to be_present
    expect(updated_ca.object.definition.name).to eq(
      { "en-US" => "team meeting updated" }.to_json
    )
    expect(updated_ca.object.definition.activity_type).to eq(
      "http://example.com/expapi/activities/meetingcategory/updated"
    )
  end

  it "creates a context activity with extensions" do
    base_statement = create(:statement)
    context =
      build(
        :context,
        context_activities: [
          build(
            :context_activity,
            object:
              build(
                :object,
                id: "http://www.example.com/meetings/series/1",
                object_type: "Activity"
              )
          )
        ],
        extensions: {
          "http://example.com/profiles/meetings/activitydefinitionextensions/room" => {
            name: "Kilby",
            id: "http://example.com/rooms/342"
          }
        },
        statement: {
          objectType: "StatementRef",
          id: base_statement.id
        }
      )

    # Create a new statement with attributes from base_statement except id
    statement_attributes =
      base_statement.attributes.except("id", "created_at", "updated_at")
    statement = create(:statement, statement_attributes.merge(context: context))

    expect(statement).to be_valid
    expect(statement.context.extensions).not_to be_empty
  end

  it "does not accept a context extension that isn't a hash" do
=======
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
>>>>>>> 6f951bba9fea07eb45e19bb596af7a54ba23a187
    context = {
      contextActivities: {
        parent: [
          {
            id: "http://www.example.com/meetings/series/1",
            objectType: "Activity"
          }
        ]
      },
<<<<<<< HEAD
      extensions:
        "http://example.com/profiles/meetings/activitydefinitionextensions/room",
      statement: {
        objectType: "StatementRef",
        id: statement.id
      }
    }

    expect { described_class.new(context) }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t(
           "rails_xapi.errors.attribute_must_be_a_hash",
           name: "extensions"
         )
    end
  end

  it "sets platform property if statement object is Activity" do
    context =
      described_class.new(
        statement: {
          objectType: "StatementRef",
          id: statement.id
        },
        platform: "platform-placeholder"
      )

    expect(context.platform).not_to be_nil
  end

  it "does not set platform property if statement object is not Activity" do
    # Build an object of type StatementRef
    statement_object =
      build(
        :object,
        objectType: "StatementRef",
        id: "9e13cefd-53d3-4eac-b5ed-2cf6693903bb"
      )

    statement = create(:statement, object: statement_object)

    context =
      build(
        :context,
        statement: {
          objectType: "StatementRef",
          id: statement.id
        },
        platform: "platform-placeholder"
      )

    test_statement =
      build(:statement, object: statement_object, context: context)

    test_statement.save!
    # Reload the statement's context activity from DB
    test_statement.context.reload

    expect(test_statement.context.platform).to be_nil
=======
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
>>>>>>> 6f951bba9fea07eb45e19bb596af7a54ba23a187
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
