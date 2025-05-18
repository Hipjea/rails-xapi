FactoryBot.define do
  factory :activity_definition, class: "RailsXapi::ActivityDefinition" do
    association :object

    trait :with_type do
      type { "http://example.com/expapi/activities/meetingcategory" }
    end

    trait :with_valid_description do
      description do
        {
          "en-GB":
            "An example meeting that happened on a specific occasion with certain people present.",
          "en-US":
            "An example meeting that happened on a specific occasion with certain people present."
        }
      end
    end

    trait :with_invalid_description do
      description do
        "An example meeting that happened on a specific occasion with certain people present."
      end
    end
  end
end
