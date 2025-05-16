FactoryBot.define do
  factory :extension, class: "RailsXapi::Extension" do
    iri do
      "http://example.com/profiles/meetings/activitydefinitionextensions/room"
    end

    value { { name: "Kilby", id: "http://example.com/rooms/342" } }
  end
end
