require "rails_helper"

RSpec.describe RailsXapi::Query, type: :service do
  describe "methods" do
    # Create 3 statements using the first 3 verb IDs
    RailsXapi::Verb::VERBS_LIST
      .keys
      .first(3)
      .each_with_index do |verb_id, i|
        let!("statement#{i + 1}".to_sym) do
          create(:statement, verb: build(:verb, id: verb_id))
        end
      end

    it "describes query verb_ids" do
      verb_ids = RailsXapi::Verb::VERBS_LIST.keys.first(3)

      expect(RailsXapi::Query.call(query: :verb_ids)).to contain_exactly(
        *verb_ids
      )
    end

    it "describes query verb_displays" do
      # Get the VERBS_LIST display values and convert them into the expected JSON values
      verb_displays =
        RailsXapi::Verb::VERBS_LIST
          .values
          .first(3)
          .map { |display| { "en-US" => display }.to_json }

      expect(RailsXapi::Query.call(query: :verb_displays)).to contain_exactly(
        *verb_displays
      )
    end

    it "describes query verbs" do
      verbs =
        RailsXapi::Verb::VERBS_LIST
          .first(3)
          .map { |verb, display| [verb, { "en-US" => display }.to_json] }

      expect(RailsXapi::Query.call(query: :verbs)).to contain_exactly(*verbs)
    end
  end

  describe "statement" do
    let(:actor) { create(:actor, :mbox) }
    let(:verb) { create(:verb) }
    let(:object) { create(:object) }
    let(:result) { create(:result) }

    let(:statement_record) do
      create(
        :statement,
        :with_context,
        actor: actor,
        verb: verb,
        object: object,
        result: result
      )
    end

    it "returns the statement with all included associations" do
      statement =
        RailsXapi::Query.call(query: :statement, args: statement_record&.id)

      expect(statement).to eq(statement_record)
      expect(statement.association(:actor)).to be_loaded
      expect(statement.association(:verb)).to be_loaded
      expect(statement.association(:object)).to be_loaded
      expect(statement.association(:context)).to be_loaded
      expect(statement.association(:result)).to be_loaded
    end

    it "raises ActiveRecord::RecordNotFound if the ID does not exist" do
      expect {
        RailsXapi::Query.call(query: :statement, args: -1)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "statements_by_object_and_actors" do
    let(:invalid_actor) { build(:actor, :invalid_mbox) }
    let(:actor) { create(:actor, :mbox) }
    let(:verb) { create(:verb) }
    let(:object) { create(:object) }
    let(:result) { create(:result) }

    let(:statement_record) do
      create(
        :statement,
        :with_context,
        actor: actor,
        verb: verb,
        object: object,
        result: result
      )
    end

    it "raises an error with no emails provided" do
      expect {
        RailsXapi::Query.call(
          query: :statements_by_object_and_actors,
          args: [object.id, []]
        )
      }.to raise_error do |error|
        expect(error).to be_a(ArgumentError)
        expect(error.message).to eq I18n.t(
             "rails_xapi.errors.no_emails_provided"
           )
      end
    end

    it "raises an error with an invalid actor's email" do
      expect {
        RailsXapi::Query.call(
          query: :statements_by_object_and_actors,
          args: [object.id, [invalid_actor.mbox]]
        )
      }.to raise_error do |error|
        expect(error).to be_a(RailsXapi::Errors::XapiError)
        expect(error.message).to eq I18n.t(
             "rails_xapi.errors.malformed_mbox",
             name: invalid_actor.mbox
           )
      end
    end

    it "returns correct results" do
      statement_record.save!

      statements =
        RailsXapi::Query.call(
          query: :statements_by_object_and_actors,
          args: [object.id, [actor.mbox]]
        )

      expect(statements.count).not_to eq(0)
      expect(statements).to include(statement_record)
    end
  end

  describe "actor_by_email" do
    let(:invalid_actor) { build(:actor, :invalid_mbox) }
    let(:actor) { create(:actor, :mbox) }
    let(:verb) { create(:verb) }
    let(:object) { create(:object) }
    let(:result) { create(:result) }

    let(:statement_record) do
      create(
        :statement,
        :with_context,
        actor: actor,
        verb: verb,
        object: object,
        result: result
      )
    end

    it "raises an error with an invalid actor's email" do
      expect {
        RailsXapi::Query.call(query: :actor_by_email, args: invalid_actor.mbox)
      }.to raise_error do |error|
        expect(error).to be_a(RailsXapi::Errors::XapiError)
        expect(error.message).to eq I18n.t(
             "rails_xapi.errors.malformed_mbox",
             name: invalid_actor.mbox
           )
      end
    end

    it "returns statements with a valid actor's email" do
      statement_record.save!

      statements =
        RailsXapi::Query.call(query: :actor_by_email, args: actor.mbox[7..-1])

      expect(statements.count).not_to eq(0)
      expect(statements).to include(statement_record)
    end

    it "returns statements when a mbox is provided" do
      statement_record.save!

      statements =
        RailsXapi::Query.call(query: :actor_by_email, args: actor.mbox)

      expect(statements.count).not_to eq(0)
      expect(statements).to include(statement_record)
    end
  end
end
