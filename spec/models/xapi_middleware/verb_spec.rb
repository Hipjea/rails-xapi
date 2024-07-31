# spec/models/result_spec.rb

require "rails_helper"

describe XapiMiddleware::Verb do
  before :each do
    XapiMiddleware::Verb.delete_all

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

# == Schema Information
#
# Table name: xapi_middleware_verbs
#
#  id           :string           not null, primary key
#  display      :string
#
# Indexes
#
#  index_xapi_middleware_verbs_on_id  (id) UNIQUE
#
