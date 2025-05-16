FactoryBot.define do
  factory :actor, class: "RailsXapi::Actor" do
    name { "Actor 1" }

    trait :mbox do
      mbox { "mailto:actor@localhost.com" }
    end

    trait :complete do
      mbox_sha1sum { "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f52" }
      account do
        RailsXapi::Account.new(
          name: "Actor#1",
          homePage: "http://example.com/actor/1"
        )
      end
      openid { "http://example.com/object/Actor#1" }
    end

    trait :group do
      name { "Team PB" }
      mbox { "mailto:teampb@example.com" }
      object_type { "Group" }
    end

    trait :group_with_members do
      group
      member do
        [
          RailsXapi::Actor.new(
            name: "Andrew Downes",
            account:
              RailsXapi::Account.new(
                homePage: "http://www.example.com",
                name: "13936749"
              ),
            object_type: "Agent"
          ),
          RailsXapi::Actor.new(
            name: "Toby Nichols",
            openid: "http://toby.openid.example.org/",
            object_type: "Agent"
          ),
          RailsXapi::Actor.new(
            name: "Ena Hills",
            mbox_sha1sum: "ebd31e95054c018b10727ccffd2ef2ec3a016ee9",
            object_type: "Agent"
          )
        ]
      end
    end
  end
end
