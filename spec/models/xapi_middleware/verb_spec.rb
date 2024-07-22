# spec/models/result_spec.rb

require "rails_helper"

describe XapiMiddleware::Verb do
  before :all do
    @base_verb = {id: XapiMiddleware::Verb::VERBS_LIST.keys[0]}
  end

  it "should be valid" do
    verb_data = @base_verb.merge(display: "example")
    verb = XapiMiddleware::Verb.new(verb_data)

    expect(verb.valid?).to be_truthy
  end

  it "should automatically set the display value" do
    verb = XapiMiddleware::Verb.new(@base_verb)
    verb.save

    expect(verb.display).to_not be_nil
  end
end
