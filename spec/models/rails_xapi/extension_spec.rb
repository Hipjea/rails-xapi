# spec/models/rails_xapi/extension_spec.rb

require "rails_helper"

describe RailsXapi::Extension do
  it "should validate prensence of attributes" do
    extension = RailsXapi::Extension.new({
      iri: nil,
      value: nil
    })

    expect { extension.save! }.to raise_error do |error|
      expect(error.to_s.include?("Iri can't be blank")).to be_truthy
      expect(error.to_s.include?("Value can't be blank")).to be_truthy
    end
  end
end
