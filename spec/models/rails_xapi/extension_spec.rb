# spec/models/rails_xapi/extension_spec.rb

require "rails_helper"

describe RailsXapi::Extension do
  it "should validate prensence of attributes" do
    extension = RailsXapi::Extension.new({ iri: nil, value: nil })

    expect { extension.save! }.to raise_error do |error|
      expect(error.to_s.include?("Iri can't be blank")).to be_truthy
      expect(error.to_s.include?("Value can't be blank")).to be_truthy
    end
  end

  it "should produce a valid as_json value" do
    extension =
      RailsXapi::Extension.new(
        {
          iri:
            "http://example.com/profiles/meetings/activitydefinitionextensions/room",
          value: {
            name: "Kilby",
            id: "http://example.com/rooms/342"
          }
        }
      )

    expect(extension.as_json).to eq(
      {
        "http://example.com/profiles/meetings/activitydefinitionextensions/room" => {
          name: "Kilby",
          id: "http://example.com/rooms/342"
        }.to_s
      }
    )
  end
end

# == Schema Information
#
# Table name: rails_xapi_extensions
#
#  id              :integer          not null, primary key
#  extendable_type :string
#  iri             :string           not null
#  value           :text             not null
#  extendable_id   :integer
#
# Indexes
#
#  index_rails_xapi_extensions_on_extendable  (extendable_type,extendable_id)
#
