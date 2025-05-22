# spec/models/rails_xapi/interaction_activity_spec.rb

require "rails_helper"

describe RailsXapi::InteractionActivity do
  let(:subject) { build(:interaction_activity) }

  describe "validations" do
    it "is valid with a supported interaction_type" do
      %w[
        true-false
        choice
        fill-in
        long-fill-in
        matching
        performance
        sequencing
        likert
        numeric
        other
      ].each do |valid_type|
        subject.interaction_type = valid_type
        expect(subject).to be_valid
      end
    end

    it "is invalid without interaction_type" do
      subject.interaction_type = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:interaction_type]).to include("can't be blank")
    end

    it "is invalid with an unsupported interaction_type" do
      subject.interaction_type = "unsupported-type"
      expect(subject).not_to be_valid
      expect(subject.errors[:interaction_type]).to include(
        "is not included in the list"
      )
    end
  end
end
