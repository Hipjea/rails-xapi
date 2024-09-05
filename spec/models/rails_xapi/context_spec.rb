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

    @object = RailsXapi::Object.new(id: "/statement-ref-object/1")

    @statement = RailsXapi::Statement.new(@default_statement)
    @statement.save!
  end

  it "should create an instructor" do
    context = RailsXapi::Context.new(instructor: @actor)

    expect(context.instructor.class).to eq(RailsXapi::Actor)
  end

  it "should create a team" do
    context = RailsXapi::Context.new(team: @actor)

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
end
