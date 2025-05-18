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
end
