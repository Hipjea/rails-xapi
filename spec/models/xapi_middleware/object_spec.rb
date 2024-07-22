# spec/models/result_spec.rb

require "rails_helper"

describe XapiMiddleware::Object do
  before :all do
    @base_object = {id: "/object/1"}

    @substatement_object = {
      objectType: "SubStatement",
      actor: {
        objectType: "Agent",
        name: "Example Admin",
        mbox: "mailto:admin@example.com"
      },
      verb: {
        id: "http://adlnet.gov/expapi/verbs/voided",
        display: {
          "en-US": "voided"
        }
      },
      object: {
        objectType: "Activity",
        id: "substatement-activity"
      }
    }
  end

  it "should be valid" do
    object = XapiMiddleware::Object.new(@base_object)

    expect(object.valid?).to be_truthy
  end

  it "should create a substatement" do
    object = XapiMiddleware::Object.new(@substatement_object)
    object.save

    expect(object.object_type).to eq("SubStatement")
    expect(object.valid?).to be_truthy
    expect(object.statement).to_not be_nil
  end
end

# == Schema Information
#
# Table name: xapi_middleware_objects
#
#  id           :string           not null, primary key
#  object_type  :string           not null
#  statement_id :bigint
#
# Indexes
#
#  index_xapi_middleware_objects_on_id            (id) UNIQUE
#  index_xapi_middleware_objects_on_statement_id  (statement_id)
#
