# spec/models/rails_xapi/verb_spec.rb

require "rails_helper"

describe RailsXapi::Verb do
<<<<<<< HEAD
  let(:verb) { build(:verb) }

  it "is valid" do
    verb_data = verb.attributes.merge(display: { "en-US" => "Example" })
    verb = described_class.new(verb_data)

    expect(verb).to be_valid
  end

  it "is not valid with an incorrect language map key" do
    verb_data = verb.attributes.merge(display: { "e" => "Example" })
    verb = described_class.new(verb_data)

    expect { verb.save! }.to raise_error(ActiveRecord::RecordInvalid) do |error|
      expect(error.record.errors[:display]).to include(
        I18n.t(
          "rails_xapi.errors.definition_description_invalid_keys",
          values: "e"
        )
      )
    end

    # Send an incorrect data type as display value
    verb_data = verb.attributes.merge(display: 1)
    verb = described_class.new(verb_data)

    expect { verb.save! }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      error_msg = I18n.t("rails_xapi.errors.expected_hash", type: Integer)
      expect(error.message).to eq(error_msg)
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
=======
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
>>>>>>> 6f951bba9fea07eb45e19bb596af7a54ba23a187
    verb.display = nil

    expect { verb.save! }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
<<<<<<< HEAD
      error_msg = I18n.t("rails_xapi.errors.missing_verb_display")
      expect(error.message).to eq(error_msg)
=======
      expect(error.message).to eq I18n.t("rails_xapi.errors.missing_verb_display")
>>>>>>> 6f951bba9fea07eb45e19bb596af7a54ba23a187
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
