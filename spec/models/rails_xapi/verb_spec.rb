# spec/models/result_spec.rb

require "rails_helper"

describe RailsXapi::Verb do
  before :each do
    RailsXapi::Verb.delete_all

    @base_verb = {id: RailsXapi::Verb::VERBS_LIST.keys[0]}
  end

  it "should be valid" do
    verb_data = @base_verb.merge(
      display: {
        "en-US" => "Example"
      }
    )
    verb = RailsXapi::Verb.new(verb_data)

    expect(verb.valid?).to be_truthy
  end

  it "should not be valid with an incorrect language map key" do
    verb_data = @base_verb.merge(
      display: {
        "e" => "Example"
      }
    )
    verb = RailsXapi::Verb.new(verb_data)

    expect { verb.save! }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t("rails_xapi.errors.definition_description_invalid_keys", values: "e")
    end
  end

  it "should automatically set the display value" do
    verb = RailsXapi::Verb.new(@base_verb)
    verb.save!

    expect(verb.display).to_not be_nil
  end

  it "should display the correct hash value" do
    verb = RailsXapi::Verb.new(@base_verb)
    verb.save!

    expect(verb.to_locale).to eq(RailsXapi::Verb::VERBS_LIST.values[0])
  end

  it "should raise an exception if no display value" do
    verb = RailsXapi::Verb.new(id: "http://example.com/verbs/not-in-the-list")
    verb.display = nil

    expect { verb.save! }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t("rails_xapi.errors.missing_verb_display")
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
