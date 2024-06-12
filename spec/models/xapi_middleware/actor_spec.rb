# spec/models/result_spec.rb

require "rails_helper"

describe XapiMiddleware::Actor do
  before :all do
    @base_actor = { name: "Actor 1" }

    @complete_actor = {
      name: "Actor 1",
      mbox_sha1sum: "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f52",
      account: {
        name: "Actor#1"
      },
      openid: "http://example.com/object/Actor#1" 
    }
  end

  it "should be valid" do
    actor = @base_actor.merge(mbox: "mailto:actor@localhost.com")
    actor = XapiMiddleware::Actor.new(actor)

    expect(actor.valid?).to be_truthy
  end

  it "should be missing the actor inverse functional identifier (IFI)" do
    expect { XapiMiddleware::Actor.new(@base_actor) }.to raise_error do |error|
      expect(error).to be_a(XapiMiddleware::Errors::XapiError)
      expect(error.message).to eq I18n.t("xapi_middleware.errors.actor_ifi_must_be_present")
    end
  end
end
