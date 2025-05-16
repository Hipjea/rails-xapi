FactoryBot.define do
  factory :statement, class: "RailsXapi::Statement" do
    association :actor, :mbox
    association :verb
    association :object
  end
end
