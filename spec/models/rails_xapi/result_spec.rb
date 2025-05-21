# spec/models/rails_xapi/result_spec.rb

require "rails_helper"

describe RailsXapi::Result do
  let(:result) { build(:result) }
  let(:statement) { build(:statement) }

  it "is valid" do
    expect(result).to be_valid
    expect(result.score[:scaled]).to eq(0.5)
    expect(result.score[:raw]).to eq(50)
    expect(result.score[:min]).to eq(1)
    expect(result.score[:max]).to eq(100)
  end

  it "is not valid with an incorrect score" do
    result = { score: { raw: 1, min: 2, max: 10 }, statement: statement }

    expect { described_class.new(result) }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t(
           "rails_xapi.errors.invalid_score_value",
           value: I18n.t("rails_xapi.validations.score.raw")
         )
    end
  end

  it "is not valid with an incorrect duration string" do
    result =
      described_class.new(duration: "IncorrectDuration", statement: statement)

    expect { result.valid? }.to raise_error do |error|
      expect(error).to be_a(
        ActiveSupport::Duration::ISO8601Parser::ParsingError
      )
      expect(
        error.message
      ).to eq 'Invalid ISO 8601 duration: "IncorrectDuration"'
    end
  end

  it "is not valid with an incorrect scaled value" do
    result = {
      score: {
        raw: 1,
        min: 2,
        max: 10,
        scaled: -1.1
      },
      statement: statement
    }

    expect { described_class.new(result) }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t(
           "rails_xapi.errors.invalid_score_value",
           value: I18n.t("rails_xapi.validations.score.scaled")
         )
    end
  end

  it "is not valid with a min value greater than max" do
    result = { score: { min: 10, max: 2 }, statement: statement }

    expect { described_class.new(result) }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t(
           "rails_xapi.errors.invalid_score_value",
           value: I18n.t("rails_xapi.validations.score.min")
         )
    end
  end

  it "has a boolean completion value" do
    completion_val = "yes"
    result = { completion: false, statement: statement }

    result_object = described_class.new(result)
    result_object.completion = completion_val
    result_object.save!

    expect(result_object.completion).to be(true)
  end

  it "sets the duration in iso8601 from seconds" do
    result = described_class.new(duration_in_seconds: 120, statement: statement)

    expect(result).to be_valid
    expect(result.duration).to eq("PT2M")
  end

  it "is not a valid extension" do
    result = {
      extensions: "http://example.com/extension/1",
      statement: statement
    }

    expect { described_class.new(result) }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      error_msg =
        I18n.t("rails_xapi.errors.attribute_must_be_a_hash", name: "extensions")
      expect(error.message).to eq(error_msg)
    end
  end
end

# == Schema Information
#
# Table name: rails_xapi_results
#
#  id           :integer          not null, primary key
#  completion   :boolean          default(FALSE)
#  duration     :string
#  response     :text
#  score_max    :integer
#  score_min    :integer
#  score_raw    :integer
#  score_scaled :decimal(3, 2)
#  success      :boolean          default(FALSE)
#  statement_id :bigint           not null
#
# Indexes
#
#  index_rails_xapi_results_on_statement_id  (statement_id)
#
