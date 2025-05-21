# spec/models/rails_xapi/result_spec.rb

require "rails_helper"

describe RailsXapi::Actor do
<<<<<<< HEAD
  let(:base_actor) { build(:actor) }
  let(:mbox_actor) { build(:actor, :mbox) }
  let(:complete_actor) { build(:actor, :complete) }
  let(:group) { build(:actor, :group) }
  let(:group_with_members) { build(:actor, :group_with_members) }

  it "is valid" do
    expect(mbox_actor).to be_valid
    expect(complete_actor).to be_valid
  end

  it "misses the actor inverse functional identifier (IFI)" do
    expect { base_actor.save }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t(
           "rails_xapi.errors.actor_ifi_must_be_present"
         )
    end
  end

  it "builds an actor from data" do
    actor = described_class.build_actor_from_data(complete_actor.attributes)

    expect(actor).to be_valid
    expect(actor.to_hash[:objectType]).to eq("Agent")
  end

  it "creates a group" do
    expect(group).to be_valid
    expect(group.to_hash[:objectType]).to eq("Group")
  end

  it "creates group members" do
    expect(group_with_members).to be_valid
    expect(group_with_members.to_hash[:objectType]).to eq("Group")
=======
  before :all do
    @base_actor = {name: "Actor 1"}

    @complete_actor = {
      name: "Actor 1",
      mbox_sha1sum: "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f52",
      account: {
        name: "Actor#1",
        homePage: "http://example.com/actor/1"
      },
      openid: "http://example.com/object/Actor#1"
    }
  end

  it "should be valid" do
    actor = @base_actor.merge(mbox: "mailto:actor@localhost.com")
    actor = RailsXapi::Actor.new(actor)

    actor_account = RailsXapi::Account.new(@complete_actor[:account])
    complete_actor = RailsXapi::Actor.new(@complete_actor.merge(account: actor_account))

    expect(actor.valid?).to be_truthy
    expect(complete_actor.valid?).to be_truthy
  end

  it "should be missing the actor inverse functional identifier (IFI)" do
    actor = RailsXapi::Actor.new(@base_actor)

    expect { actor.save }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t("rails_xapi.errors.actor_ifi_must_be_present")
    end
  end

  it "should build an actor from data" do
    actor = RailsXapi::Actor.build_actor_from_data(@complete_actor)

    expect(actor.valid?).to be_truthy
    expect(actor.to_hash[:objectType]).to eq("Agent")
  end

  it "should create a group" do
    actor = RailsXapi::Actor.build_actor_from_data({
      name: "Team PB",
      mbox: "mailto:teampb@example.com",
      objectType: "Group"
    })

    expect(actor.valid?).to be_truthy
    expect(actor.to_hash[:objectType]).to eq("Group")
  end

  it "should create group members" do
    actor = RailsXapi::Actor.build_actor_from_data({
      name: "Team PB",
      mbox: "mailto:teampb@example.com",
      objectType: "Group",
      member: [
        {
          name: "Andrew Downes",
          account: {
            homePage: "http://www.example.com",
            name: "13936749"
          },
          objectType: "Agent"
        },
        {
          name: "Toby Nichols",
          openid: "http://toby.openid.example.org/",
          objectType: "Agent"
        },
        {
          name: "Ena Hills",
          mbox_sha1sum: "ebd31e95054c018b10727ccffd2ef2ec3a016ee9",
          objectType: "Agent"
        }
      ]
    })

    expect(actor.valid?).to be_truthy
    expect(actor.to_hash[:objectType]).to eq("Group")
>>>>>>> 6f951bba9fea07eb45e19bb596af7a54ba23a187
  end
end

# == Schema Information
#
# Table name: rails_xapi_actors
#
#  id           :integer          not null, primary key
#  mbox         :string
#  mbox_sha1sum :string
#  name         :string
#  object_type  :string
#  openid       :string
#  created_at   :datetime         not null
#
