FactoryBot.define do
  factory :context_activity, class: "RailsXapi::ContextActivity" do
    association :context
    association :object, factory: :object
    activity_type { "parent" }

    trait :parent_series_1 do
      activity_type { "parent" }
      object do
        build(
          :object,
          id: "http://www.example.com/meetings/series/1",
          object_type: "Activity"
        )
      end
    end

    trait :parent_series_2 do
      activity_type { "parent" }
      object do
        build(
          :object,
          id: "http://www.example.com/meetings/series/2",
          object_type: "Activity"
        )
      end
    end

    trait :category do
      after(:build) do |context_activity|
        context_activity.object =
          build(
            :object,
            id: "http://www.example.com/meetings/categories/teammeeting",
            object_type: "Activity",
            definition:
              build(
                :definition,
                name: {
                  "en-US" => "team meeting"
                },
                description: {
                  "en-US" =>
                    "A category of meeting used for regular team meetings."
                },
                type: "http://example.com/expapi/activities/meetingcategory"
              )
          )
      end
    end
  end
end
