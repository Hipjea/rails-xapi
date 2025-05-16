FactoryBot.define do
  factory :activity_definition, class: "RailsXapi::ActivityDefinition" do
    association :object
  end
end
