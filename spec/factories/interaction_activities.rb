FactoryBot.define do
  factory :interaction_activity, class: "RailsXapi::InteractionActivity" do
    interaction_type { "true-false" }
    correct_responses_pattern { ["true"] }
    association :activity_definition
  end
end
