# spec/models/rails_xapi/verb_spec.rb

require "rails_helper"

describe RailsXapi::Verb do
  let(:verb) { build(:verb) }

  it "is valid" do
    verb_data = verb.attributes.merge(display: { "en-US" => "Example" })
    verb = described_class.new(verb_data)

    expect(verb).to be_valid
  end

  it "is not valid with an incorrect language map key" do
    verb_data = verb.attributes.merge(display: { "e" => "Example" })
    verb = described_class.new(verb_data)

    expect { verb.save! }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t(
           "rails_xapi.errors.definition_description_invalid_keys",
           values: "e"
         )
    end
  end

  it "sets the display value automatically" do
    verb.save!

    expect(verb.display).not_to be_nil
  end

  it "displays the correct hash value" do
    verb = create(:verb)
    expected_value = RailsXapi::Verb::VERBS_LIST[verb.id]

    expect(expected_value).not_to be_nil
    expect(verb.to_locale).to eq(expected_value)
  end

  it "raises an exception if no display value" do
    verb = described_class.new(id: "http://example.com/verbs/not-in-the-list")
    verb.display = nil

    expect { verb.save! }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t(
           "rails_xapi.errors.missing_verb_display"
         )
    end
  end
end

# == Schema Information
#
# Table name: rails_xapi_verbs
#
#  id      :string           not null, primary key
#  display :string
#
# Indexes
#
#  index_rails_xapi_verbs_on_id  (id) UNIQUE
#
