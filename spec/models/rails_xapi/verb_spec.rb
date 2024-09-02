# spec/models/result_spec.rb

require "rails_helper"

describe RailsXapi::Verb do
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

  it "should automatically set the display value" do
    verb = RailsXapi::Verb.new(@base_verb)
    verb.save

    expect(verb.display).to_not be_nil
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
