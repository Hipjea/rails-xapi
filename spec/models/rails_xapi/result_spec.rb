# spec/models/result_spec.rb

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
