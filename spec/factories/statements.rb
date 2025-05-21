FactoryBot.define do
  factory :statement, class: "RailsXapi::Statement" do
    association :actor, :mbox
    association :verb
    association :object

    trait :with_context do
      after(:build) do |statement|
        statement.context = build(:context, statement: statement)

        # Add 2 parent context activities
        statement.context.context_activities << build(
          :context_activity,
          :parent_series_1,
          context: statement.context
        )
        statement.context.context_activities << build(
          :context_activity,
          :parent_series_2,
          context: statement.context
        )

        statement.context.statement_ref = statement
      end
    end

    trait :without_actor do
      actor { nil }
    end

    trait :with_substatement do
      object { :substatement }
    end
  end
end
