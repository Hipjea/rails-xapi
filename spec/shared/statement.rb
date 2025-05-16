RSpec.shared_context "statement" do
  before :each do
    def build_statement(actor_num:, verb_index:)
      {
        actor: {
          name: "Actor #{actor_num}",
          mbox_sha1sum:
            "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f5#{actor_num}",
          openid: "http://example.com/object/Actor##{actor_num}"
        },
        verb: {
          id: RailsXapi::Verb::VERBS_LIST.keys[verb_index]
        },
        object: {
          id: "/object/#{actor_num}"
        }
      }
    end

    @verb = RailsXapi::Verb.new(id: RailsXapi::Verb::VERBS_LIST.keys[0])

    @actor =
      RailsXapi::Actor.new(
        name: "Actor 1",
        mbox_sha1sum: "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f52",
        openid: "http://example.com/object/Actor#1"
      )

    @object = RailsXapi::Object.new(id: "/object/1")

    @default_statement = { verb: @verb, object: @object, actor: @actor }
  end
end
