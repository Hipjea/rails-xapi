FactoryBot.define do
  factory :result, class: "RailsXapi::Result" do
    score { { score_scaled: 0.5, raw: 50, min: 1, max: 100 } }
    response { "The actor 1 answered" }
    success { true }
    completion { "false" }
    duration { "PT4H35M59.14S" }
    extensions do
      {
        "http://example.com/extension/1": "empty",
        "http://example.com/extension/2": "also empty"
      }
    end
    association :statement
  end
end
