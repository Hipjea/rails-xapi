FactoryBot.define do
  sequence(:verb_key) do |n|
    RailsXapi::Verb::VERBS_LIST.keys[n % RailsXapi::Verb::VERBS_LIST.keys.size]
  end

  factory :verb, class: "RailsXapi::Verb" do
    id { generate(:verb_key) }

    trait :with_invalid_display do
      display { "en-US" }
    end
  end
end
