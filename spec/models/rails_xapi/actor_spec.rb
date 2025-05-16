# spec/models/rails_xapi/result_spec.rb

require "rails_helper"

describe RailsXapi::Actor do
  let(:base_actor) { build(:actor) }
  let(:mbox_actor) { build(:actor, :mbox) }
  let(:complete_actor) { build(:actor, :complete) }
  let(:group) { build(:actor, :group) }
  let(:group_with_members) { build(:actor, :group_with_members) }

  it "should be valid" do
    expect(mbox_actor.valid?).to be_truthy
    expect(complete_actor.valid?).to be_truthy
  end

  it "should be missing the actor inverse functional identifier (IFI)" do
    expect { base_actor.save }.to raise_error do |error|
      expect(error).to be_a(RailsXapi::Errors::XapiError)
      expect(error.message).to eq I18n.t(
           "rails_xapi.errors.actor_ifi_must_be_present"
         )
    end
  end

  it "should build an actor from data" do
    actor = RailsXapi::Actor.build_actor_from_data(complete_actor.attributes)

    expect(actor.valid?).to be_truthy
    expect(actor.to_hash[:objectType]).to eq("Agent")
  end

  it "should create a group" do
    expect(group.valid?).to be_truthy
    expect(group.to_hash[:objectType]).to eq("Group")
  end

  it "should create group members" do
    expect(group_with_members.valid?).to be_truthy
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
