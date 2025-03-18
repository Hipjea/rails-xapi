require "rails_helper"

RSpec.describe RailsXapi::StatementCreator, type: :service do
  before :all do
    @actor = {
      name: "Actor 1",
      mbox_sha1sum: "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f52",
      openid: "http://example.com/object/Actor#1"
    }

    @statement = {
      actor: @actor,
      verb: {
        id: RailsXapi::Verb::VERBS_LIST.keys[0]
      },
      object: {
        id: "/object/1"
      }
    }
  end

  describe "PATCH /users/patch/option" do
    it "calls the statement creator service" do
      statement_creator = RailsXapi::StatementCreator.new(@statement, @actor)
      result = statement_creator.call
      status, statement = result.values_at(:status, :statement)

      expect(status).to eq(200)
      expect(statement.is_a?(RailsXapi::Statement)).to be_truthy
    end
  end
end
