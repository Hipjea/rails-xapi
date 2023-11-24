# frozen_string_literal: true

module XapiMiddleware
  class Statement
    def initialize(verb_uri:, object_id: nil, object_name: nil, actor_name: nil, actor_mbox: nil)
      @verb_uri = verb_uri
      @object_id = object_id
      @object_name = object_name
      @actor_name = actor_name
      @actor_mbox = actor_mbox
    end

    def define
      actor.name = @actor_name
      actor.mbox = @actor_mbox
      object.id = @object_id
      object.definition.name = @object_name
    end

    def output
      self
    end

    private

      def initialize_components
        @actor ||= Xapi::Actor.new
        @object ||= Xapi::Object.new
        @verb ||= Xapi::Verb.new(@verb_uri)
      end
  end
end
