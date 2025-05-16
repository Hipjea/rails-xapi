FactoryBot.define do
  factory :object, class: 'RailsXapi::Object' do
    sequence(:id) { |n| "/object/#{n}" }

    trait :activity do
      id { "substatement-activity" }
      object_type { "Activity" }
    end

    trait :substatement do
      object_type { "SubStatement" }
      actor {
        {
          name: "Actor 1",
          mbox: "mailto:actor@localhost.com"
        }
      }
      verb {
        {
          id: RailsXapi::Verb::VERBS_LIST.keys.sample,
          display: { "en-US" => "completed" }
        }
      }
      object {
        {
          id: "/object/#{rand(1000)}",
          objectType: "Activity"
        }
      }
      timestamp { Time.zone.now }
    end

    trait :invalid_object_type do
      object_type { "Rogue" }
    end

    trait :with_activity_definition do
      definition {
        {
          name: {"en-US" => "object definition"},
          description: {"en" => "Object definition"},
          type: "Activity",
          extensions: {
            "http://example.com/profiles/meetings/activitydefinitionextensions/room": {
              "name": "Kilby",
              "id": "http://example.com/rooms/342"
            }
          },
          moreInfo: "http://example.com/more_infos"
        }
      }
    end

    trait :with_invalid_activity_definition do
      definition {
        {
          name: {"en-US" => "object definition"},
          extensions: "http://example.com/profiles/meetings/activitydefinitionextensions/room"
        }
      }
    end
  end
end
