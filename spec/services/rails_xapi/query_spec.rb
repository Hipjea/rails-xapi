require "rails_helper"

RSpec.describe RailsXapi::Query, type: :service do
  include_context "statement"

  before :all do
    @statement_1 = build_statement(1, 0)
    @statement_2 = build_statement(2, 1)
    @statement_3 = build_statement(3, 2)
  end

  describe "methods" do
    it "describes query verb_ids" do
      @statement_1.call
      @statement_2.call
      @statement_3.call

      verb_ids = RailsXapi::Verb::VERBS_LIST.keys.first(3)

      expect(RailsXapi::Query.call(query: :verb_ids)).to contain_exactly(*verb_ids)
    end

    it "describes query verb_displays" do
      @statement_1.call
      @statement_2.call
      @statement_3.call

      # Get the VERBS_LIST display values and convert them into the expected JSON value.s
      verb_displays = RailsXapi::Verb::VERBS_LIST.values.first(3).map do |display|
        {"en-US" => display}.to_json
      end

      expect(RailsXapi::Query.call(query: :verb_displays)).to contain_exactly(*verb_displays)
    end

    it "describes query verbs" do
      @statement_1.call
      @statement_2.call
      @statement_3.call

      verbs = RailsXapi::Verb::VERBS_LIST.first(3).map do |verb, display|
        [verb, {"en-US" => display}.to_json]
      end

      expect(RailsXapi::Query.call(query: :verbs)).to contain_exactly(*verbs)
    end
  end
end
