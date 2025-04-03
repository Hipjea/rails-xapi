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
    it "creates a statement through a call to the statement creator service" do
      statement_creator = RailsXapi::StatementCreator.new(@statement.merge(actor: @actor))
      result = statement_creator.call
      status, statement = result.values_at(:status, :statement)

      expect(status).to eq(200)
      expect(statement.is_a?(RailsXapi::Statement)).to be_truthy
      expect { statement.as_json }.not_to raise_error
    end

    it "creates a statement through an asynchronous call to the statement creator service" do
      statement_creator = RailsXapi::StatementCreator.new(@statement.merge(actor: @actor))

      expect { statement_creator.call(async: true) }.to change {
        RailsXapi::Statement.count
      }.by(1)
    end

    it "creates a statement with a given @actor instance variable" do
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
      current_time = (Time.zone.now - 2.hours).freeze
      statement_creator = RailsXapi::StatementCreator.new(@statement.merge(actor: @actor, timestamp: current_time))
      result = statement_creator.call
      status, statement = result.values_at(:status, :statement)

      expect(status).to eq(200)
      expect(statement.timestamp).to eq(current_time)
    end
  end
end
