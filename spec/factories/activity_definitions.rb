FactoryBot.define do
  factory :actovity_definitions, class: 'RailsXapi::ActivityDefinition' do
    association :object
  end
end
