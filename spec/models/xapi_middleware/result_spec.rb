# spec/models/result_spec.rb

require "rails_helper"

describe XapiMiddleware::Result do
  before :all do
    @base_result = { 
      score_raw: 50,
      score_min: 0,
      score_max: 100
    }
  end

  it "should be valid" do
    result = @base_result.merge(
      response: "The actor 1 answered",
      success: true,
      completion: "false",
      duration: "PT4H35M59.14S",
      extensions: {
        "http://example.com/extension/1": "empty",
        "http://example.com/extension/2": "also empty"
      }
    )
    result = XapiMiddleware::Result.new(result)

    expect(result.valid?).to be_truthy
  end

  it "should not be valid with wrong extension URI" do
    result = @base_result.merge(extensions: {"htt://example.com/ext": "empty"})

    expect { XapiMiddleware::Result.new(result) }.to raise_error do |error|
      expect(error).to be_a(XapiMiddleware::Errors::XapiError)
      expect(error.message).to eq I18n.t("xapi_middleware.errors.malformed_uri", uri: result[:extensions].keys[0])
    end
  end

  it "should not be valid with an empty extension value" do
    result = @base_result.merge(extensions: {"http://example.com/ext": nil})

    expect { XapiMiddleware::Result.new(result) }.to raise_error do |error|
      expect(error).to be_a(XapiMiddleware::Errors::XapiError)
      expect(error.message).to eq I18n.t("xapi_middleware.errors.value_must_not_be_nil", name: result[:extensions].keys[0])
    end
  end

  it "should not be valid with an incorrect duration string" do
    result = @base_result.merge(duration: "IncorrectDuration")

    expect { XapiMiddleware::Result.new(result) }.to raise_error do |error|
      expect(error).to be_a(ActiveSupport::Duration::ISO8601Parser::ParsingError)
      expect(error.message).to eq 'Invalid ISO 8601 duration: "IncorrectDuration"'
    end
  end

  it "should not be valid with an incorrect success value" do
    result = @base_result.merge(success: "truthy")

    expect { XapiMiddleware::Result.new(result) }.to raise_error do |error|
      expect(error).to be_a(XapiMiddleware::Errors::XapiError)
      expect(error.message).to eq I18n.t("xapi_middleware.errors.wrong_attribute_type", name: "success", value: result[:success])
    end
  end

  it "should not be valid with an incorrect completion value" do
    result = @base_result.merge(completion: "truthy")

    expect { XapiMiddleware::Result.new(result) }.to raise_error do |error|
      expect(error).to be_a(XapiMiddleware::Errors::XapiError)
      expect(error.message).to eq I18n.t("xapi_middleware.errors.wrong_attribute_type", name: "completion", value: result[:completion])
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
