FactoryBot.define do
  factory :object, class: "RailsXapi::Object" do
    sequence(:id) { |n| "/object/#{n}" }
    object_type { "Activity" }
    definition { nil }

    trait :activity do
      id { "substatement-activity" }
      object_type { "Activity" }
    end

    trait :substatement do
      object_type { "SubStatement" }
      actor { { name: "Actor 1", mbox: "mailto:actor@localhost.com" } }
      verb do
        {
          id: RailsXapi::Verb::VERBS_LIST.keys.sample,
          display: {
            "en-US" => "completed"
          }
        }
      end
      object { { id: "/object/#{rand(1000)}", objectType: "Activity" } }
      timestamp { Time.zone.now }
    end

    trait :with_activity_definition do
      definition do
        {
          name: {
            "en-US" => "object definition"
          },
          description: {
            "en" => "Object definition"
          },
          type: "Activity",
          extensions: {
            "http://example.com/profiles/meetings/activitydefinitionextensions/room": {
              name: "Kilby",
              id: "http://example.com/rooms/342"
            }
          },
          moreInfo: "http://example.com/more_infos"
        }
      end
    end

    trait :with_invalid_activity_definition do
      definition do
        {
          name: {
            "en-US" => "object definition"
          },
          extensions:
            "http://example.com/profiles/meetings/activitydefinitionextensions/room"
        }
      end
    end

    trait :with_definition do
      definition do
        {
          name: {
            "en-US" => "default name"
          },
          description: {
            "en-US" => "default description"
          },
          activity_type: "http://example.com/expapi/activities/default"
        }
      end
    end
  end
end
