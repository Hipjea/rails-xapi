FactoryBot.define do
  factory :verb, class: "RailsXapi::Verb" do
    id { RailsXapi::Verb::VERBS_LIST.keys.sample }
  end
end
