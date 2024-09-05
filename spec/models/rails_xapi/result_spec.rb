# spec/models/rails_xapi/result_spec.rb

require "rails_helper"

describe RailsXapi::Result do
  before :all do
    @verb = RailsXapi::Verb.new(id: RailsXapi::Verb::VERBS_LIST.keys[0])
    @actor = RailsXapi::Actor.new(name: "Actor 1", openid: "http://example.com/object/Actor#1")
    @object = RailsXapi::Object.new(id: "/object/1")
    @default_statement = {verb: @verb, object: @object, actor: @actor}
  end

  it "should be valid" do
    result = RailsXapi::Result.new(
      score: {
        raw: 50,
        min: 0,
        max: 100
      },
      response: "The actor 1 answered",
      success: true,
      completion: "false",
      duration: "PT4H35M59.14S",
      extensions: {
        "http://example.com/extension/1": "empty",
        "http://example.com/extension/2": "also empty"
      },
      statement: RailsXapi::Statement.new(@default_statement)
    )

    expect(result.valid?).to be_truthy
  end

  it "should not be valid with an incorrect score" do
    result = {
      score: {
        raw: 1,
        min: 2,
        max: 10
      },
      statement: RailsXapi::Statement.new(@default_statement)
    }

    expect { RailsXapi::Result.new(result) }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t("rails_xapi.errors.invalid_score_value",
        value: I18n.t("rails_xapi.validations.score.raw"))
    end
  end

  it "should not be valid with an incorrect duration string" do
    result = RailsXapi::Result.new(
      duration: "IncorrectDuration",
      statement: RailsXapi::Statement.new(@default_statement)
    )

    expect { result.valid? }.to raise_error do |error|
      expect(error).to be_a(ActiveSupport::Duration::ISO8601Parser::ParsingError)
      expect(error.message).to eq 'Invalid ISO 8601 duration: "IncorrectDuration"'
    end
  end

  it "should not be valid with an incorrect scaled value" do
    result = {
      score: {
        raw: 1,
        min: 2,
        max: 10,
        scaled: -1.1
      },
      statement: RailsXapi::Statement.new(@default_statement)
    }

    expect { RailsXapi::Result.new(result) }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t("rails_xapi.errors.invalid_score_value",
        value: I18n.t("rails_xapi.validations.score.scaled"))
    end
  end

  it "should not be valid with a min value greater than max" do
    result = {
      score: {
        min: 10,
        max: 2
      },
      statement: RailsXapi::Statement.new(@default_statement)
    }

    expect { RailsXapi::Result.new(result) }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t("rails_xapi.errors.invalid_score_value",
        value: I18n.t("rails_xapi.validations.score.min"))
    end
  end

  it "should have a boolean completion value" do
    completion_val = "yes"
    result = {
      completion: false,
      statement: RailsXapi::Statement.new(@default_statement)
    }

    result_object = RailsXapi::Result.new(result)
    result_object.completion = completion_val
    result_object.save!

    expect(result_object.completion).to eq(true)
  end

  it "should set the duration in iso8601 from seconds" do
    result = RailsXapi::Result.new(
      duration_in_seconds: 120,
      statement: RailsXapi::Statement.new(@default_statement)
    )

    expect(result.valid?).to be_truthy
    expect(result.duration).to eq("PT2M")
  end

  it "should not be a valid extension" do
    result = {
      extensions: "http://example.com/extension/1",
      statement: RailsXapi::Statement.new(@default_statement)
    }

    expect { RailsXapi::Result.new(result) }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t("rails_xapi.errors.attribute_must_be_a_hash", name: "extensions")
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
