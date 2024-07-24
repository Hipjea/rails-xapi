# spec/models/result_spec.rb

require "rails_helper"

describe XapiMiddleware::Result do
  before :all do
    @verb = XapiMiddleware::Verb.new(id: XapiMiddleware::Verb::VERBS_LIST.keys[0])
    @actor = XapiMiddleware::Actor.new(name: "Actor 1", openid: "http://example.com/object/Actor#1")
    @object = XapiMiddleware::Object.new(id: "/object/1")
    @default_statement = {verb: @verb, object: @object, actor: @actor}
  end

  it "should be valid" do
    result = XapiMiddleware::Result.new(
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
      statement: XapiMiddleware::Statement.new(@default_statement)
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
      statement: XapiMiddleware::Statement.new(@default_statement)
    }

    expect { XapiMiddleware::Result.new(result) }.to raise_error do |error|
      expect(error).to be_a(XapiMiddleware::Errors::XapiError)
      expect(error.message).to eq I18n.t("xapi_middleware.errors.invalid_score_value",
        value: I18n.t("xapi_middleware.validations.score.raw"))
    end
  end

  it "should not be valid with an incorrect duration string" do
    result = XapiMiddleware::Result.new(
      duration: "IncorrectDuration",
      statement: XapiMiddleware::Statement.new(@default_statement)
    )

    expect { result.valid? }.to raise_error do |error|
      expect(error).to be_a(ActiveSupport::Duration::ISO8601Parser::ParsingError)
      expect(error.message).to eq 'Invalid ISO 8601 duration: "IncorrectDuration"'
    end
  end
end

# == Schema Information
#
# Table name: xapi_middleware_results
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
#  index_xapi_middleware_results_on_statement_id  (statement_id)
#
