# spec/models/rails_xapi/result_spec.rb

require "rails_helper"

describe RailsXapi::Actor do
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
    actor = RailsXapi::Actor.build_from_data(@complete_actor, "actor@example.com")

    expect(actor.valid?).to be_truthy
  end

  it "should create the correct hash of the actor's data" do
    actor = RailsXapi::Actor.build_from_data(@complete_actor, "actor@example.com")

    expect(actor.to_hash[:objectType]).to eq("Agent")
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
