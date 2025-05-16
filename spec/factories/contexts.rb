FactoryBot.define do
  factory :context, class: "RailsXapi::Context" do
    statement { nil }
    statement_ref { nil }

    after(:build) { |context| context.context_activities ||= [] }

    trait :with_context_activities do
      context_activities
    end

    trait :with_instructor do
      statement
      instructor do
        {
          name: "Actor 1",
          mbox_sha1sum: "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f52",
          openid: "http://example.com/object/Actor#1"
        }
      end
    end

    trait :with_team do
      statement
      team do
        {
          name: "Team PB",
          mbox: "mailto:teampb@example.com",
          objectType: "Group"
        }
      end
    end

    trait :with_instructor_and_team do
      with_instructor
      with_team
    end

    trait :with_statement_ref do
      statement_ref { { objectType: "StatementRef", id: statement.id } }
    end
  end
end
