FactoryBot.define do
  factory :statement, class: "RailsXapi::Statement" do
    association :actor
    association :verb
    association :object
  end
end
