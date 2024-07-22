# spec/models/result_spec.rb

require "rails_helper"

describe XapiMiddleware::Object do
  before :all do
    @base_object = {id: "/object/1"}
  end

  it "should be valid" do
    object = XapiMiddleware::Object.new(@base_object)

    expect(object.valid?).to be_truthy
  end
end
