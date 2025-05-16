require "rails_helper"

RSpec.describe RailsXapi::Query, type: :service do
  include_context "statement"

  before :each do
    @statement_1 =
      RailsXapi::StatementCreator.create(
        build_statement(actor_num: 1, verb_index: 0)
      )
    @statement_2 =
      RailsXapi::StatementCreator.create(
        build_statement(actor_num: 2, verb_index: 1)
      )
    @statement_3 =
      RailsXapi::StatementCreator.create(
        build_statement(actor_num: 3, verb_index: 2)
      )
  end

  describe "methods" do
    it "describes query verb_ids" do
      verb_ids = RailsXapi::Verb::VERBS_LIST.keys.first(3)

      expect(RailsXapi::Query.call(query: :verb_ids)).to contain_exactly(
        *verb_ids
      )
    end

    it "describes query verb_displays" do
      # Get the VERBS_LIST display values and convert them into the expected JSON value.s
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
end
