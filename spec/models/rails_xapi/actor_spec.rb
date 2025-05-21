# spec/models/rails_xapi/result_spec.rb

require "rails_helper"

describe RailsXapi::Actor do
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
