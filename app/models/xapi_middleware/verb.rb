# frozen_string_literal: true

module XapiMiddleware
  # Representation class of an error raised by the Verb class.
  class VerbError < StandardError; end

  class Verb
    # The Verb defines the action between an Actor and an Activity.
    # The systems reading the statements must use the verb IRI to infer meaning.
    # See : https://github.com/adlnet/xAPI-Spec/blob/master/xAPI-Data.md#243-verb

    attr_accessor :id, :display
    attr_reader :generic_display

    # Constants representing a mapping of xAPI activity verbs.
    #
    # The constant maps the activity verbs from several schemas
    # to their corresponding human-readable output.
    #
    # @example Usage:
    #   VERBS_LIST["http://activitystrea.ms/schema/1.0/accept"]  # => "accepted"
    #   VERBS_LIST["http://activitystrea.ms/schema/1.0/access"]  # => "accessed"
    #
    # @note The list is build from https://registry.tincanapi.com/#home/verbs
    VERBS_LIST = {
      "http://activitystrea.ms/schema/1.0/accept" => "accepted",
      "http://activitystrea.ms/schema/1.0/access" => "accessed",
      "http://activitystrea.ms/schema/1.0/acknowledge" => "acknowledged",
      "http://activitystrea.ms/schema/1.0/add" => "added",
      "http://activitystrea.ms/schema/1.0/agree" => "agreed",
      "http://activitystrea.ms/schema/1.0/append" => "appended",
      "http://activitystrea.ms/schema/1.0/approve" => "approved",
      "http://activitystrea.ms/schema/1.0/archive" => "archived",
      "http://activitystrea.ms/schema/1.0/assign" => "assigned",
      "http://activitystrea.ms/schema/1.0/at" => "was at",
      "http://activitystrea.ms/schema/1.0/attach" => "attached",
      "http://activitystrea.ms/schema/1.0/attend" => "attended",
      "http://activitystrea.ms/schema/1.0/author" => "authored",
      "http://activitystrea.ms/schema/1.0/authorize" => "authorized",
      "http://activitystrea.ms/schema/1.0/borrow" => "borrowed",
      "http://activitystrea.ms/schema/1.0/build" => "built",
      "http://activitystrea.ms/schema/1.0/cancel" => "canceled",
      "http://activitystrea.ms/schema/1.0/checkin" => "checked in",
      "http://activitystrea.ms/schema/1.0/close" => "closed",
      "http://activitystrea.ms/schema/1.0/complete" => "completed",
      "http://activitystrea.ms/schema/1.0/confirm" => "confirmed",
      "http://activitystrea.ms/schema/1.0/consume" => "consumed",
      "http://activitystrea.ms/schema/1.0/create" => "created",
      "http://activitystrea.ms/schema/1.0/delete" => "deleted",
      "http://activitystrea.ms/schema/1.0/deliver" => "delivered",
      "http://activitystrea.ms/schema/1.0/deny" => "denied",
      "http://activitystrea.ms/schema/1.0/disagree" => "disagreed",
      "http://activitystrea.ms/schema/1.0/dislike" => "disliked",
      "http://activitystrea.ms/schema/1.0/experience" => "experienced",
      "http://activitystrea.ms/schema/1.0/favorite" => "favorited",
      "http://activitystrea.ms/schema/1.0/find" => "found",
      "http://activitystrea.ms/schema/1.0/flag-as-inappropriate" => "flagged as inappropriate",
      "http://activitystrea.ms/schema/1.0/follow" => "followed",
      "http://activitystrea.ms/schema/1.0/give" => "gave",
      "http://activitystrea.ms/schema/1.0/host" => "hosted",
      "http://activitystrea.ms/schema/1.0/ignore" => "ignored",
      "http://activitystrea.ms/schema/1.0/insert" => "inserted",
      "http://activitystrea.ms/schema/1.0/install" => "installed",
      "http://activitystrea.ms/schema/1.0/interact" => "interacted",
      "http://activitystrea.ms/schema/1.0/invite" => "invited",
      "http://activitystrea.ms/schema/1.0/join" => "joined",
      "http://activitystrea.ms/schema/1.0/leave" => "left",
      "http://activitystrea.ms/schema/1.0/like" => "liked",
      "http://activitystrea.ms/schema/1.0/listen" => "listened",
      "http://activitystrea.ms/schema/1.0/lose" => "lost",
      "http://activitystrea.ms/schema/1.0/make-friend" => "made friend",
      "http://activitystrea.ms/schema/1.0/open" => "opened",
      "http://activitystrea.ms/schema/1.0/play" => "played",
      "http://activitystrea.ms/schema/1.0/present" => "presented",
      "http://activitystrea.ms/schema/1.0/purchase" => "purchased",
      "http://activitystrea.ms/schema/1.0/qualify" => "qualified",
      "http://activitystrea.ms/schema/1.0/read" => "read",
      "http://activitystrea.ms/schema/1.0/receive" => "received",
      "http://activitystrea.ms/schema/1.0/reject" => "rejected",
      "http://activitystrea.ms/schema/1.0/remove" => "removed",
      "http://activitystrea.ms/schema/1.0/remove-friend" => "removed friend",
      "http://activitystrea.ms/schema/1.0/replace" => "replaced",
      "http://activitystrea.ms/schema/1.0/request" => "requested",
      "http://activitystrea.ms/schema/1.0/request-friend" => "requested friend",
      "http://activitystrea.ms/schema/1.0/resolve" => "resolved",
      "http://activitystrea.ms/schema/1.0/retract" => "retracted",
      "http://activitystrea.ms/schema/1.0/return" => "returned",
      "http://activitystrea.ms/schema/1.0/rsvp-maybe" => "RSVPed maybe",
      "http://activitystrea.ms/schema/1.0/rsvp-no" => "rsvped no",
      "http://activitystrea.ms/schema/1.0/rsvp-yes" => "rsvped yes",
      "http://activitystrea.ms/schema/1.0/satisfy" => "satisfied",
      "http://activitystrea.ms/schema/1.0/save" => "saved",
      "http://activitystrea.ms/schema/1.0/schedule" => "scheduled",
      "http://activitystrea.ms/schema/1.0/search" => "searched",
      "http://activitystrea.ms/schema/1.0/sell" => "sold",
      "http://activitystrea.ms/schema/1.0/send" => "sent",
      "http://activitystrea.ms/schema/1.0/share" => "shared",
      "http://activitystrea.ms/schema/1.0/sponsor" => "sponsored",
      "http://activitystrea.ms/schema/1.0/start" => "started",
      "http://activitystrea.ms/schema/1.0/stop-following" => "stopped following",
      "http://activitystrea.ms/schema/1.0/submit" => "submitted",
      "http://activitystrea.ms/schema/1.0/tag" => "tagged",
      "http://activitystrea.ms/schema/1.0/terminate" => "terminated",
      "http://activitystrea.ms/schema/1.0/tie" => "tied",
      "http://activitystrea.ms/schema/1.0/unfavorite" => "unfavorited",
      "http://activitystrea.ms/schema/1.0/unlike" => "unliked",
      "http://activitystrea.ms/schema/1.0/unsatisfy" => "unsatisfied",
      "http://activitystrea.ms/schema/1.0/unsave" => "unsaved",
      "http://activitystrea.ms/schema/1.0/unshare" => "unshared",
      "http://activitystrea.ms/schema/1.0/update" => "updated",
      "http://activitystrea.ms/schema/1.0/use" => "used",
      "http://activitystrea.ms/schema/1.0/watch" => "Watched",
      "http://activitystrea.ms/schema/1.0/win" => "won",
      "http://adlnet.gov/expapi/verbs/answered" => "answered",
      "http://adlnet.gov/expapi/verbs/asked" => "asked",
      "http://adlnet.gov/expapi/verbs/attempted" => "attempted",
      "http://adlnet.gov/expapi/verbs/attended" => "attended",
      "http://adlnet.gov/expapi/verbs/commented" => "commented",
      "http://adlnet.gov/expapi/verbs/completed" => "completed",
      "http://adlnet.gov/expapi/verbs/exited" => "exited",
      "http://adlnet.gov/expapi/verbs/experienced" => "experienced",
      "http://adlnet.gov/expapi/verbs/failed" => "failed",
      "http://adlnet.gov/expapi/verbs/imported" => "imported",
      "http://adlnet.gov/expapi/verbs/initialized" => "initialized",
      "http://adlnet.gov/expapi/verbs/interacted" => "interacted",
      "http://adlnet.gov/expapi/verbs/launched" => "launched",
      "http://adlnet.gov/expapi/verbs/mastered" => "mastered",
      "http://adlnet.gov/expapi/verbs/passed" => "passed",
      "http://adlnet.gov/expapi/verbs/preferred" => "preferred",
      "http://adlnet.gov/expapi/verbs/progressed" => "progressed",
      "http://adlnet.gov/expapi/verbs/registered" => "registered",
      "http://adlnet.gov/expapi/verbs/responded" => "responded",
      "http://adlnet.gov/expapi/verbs/resumed" => "resumed",
      "http://adlnet.gov/expapi/verbs/scored" => "scored",
      "http://adlnet.gov/expapi/verbs/shared" => "shared",
      "http://adlnet.gov/expapi/verbs/suspended" => "suspended",
      "http://adlnet.gov/expapi/verbs/terminated" => "terminated",
      "http://adlnet.gov/expapi/verbs/voided" => "voided",
      "http://curatr3.com/define/verb/edited" => "edited",
      "http://curatr3.com/define/verb/voted-down" => "voted down (with reason)",
      "http://curatr3.com/define/verb/voted-up" => "voted up (with reason)",
      "http://future-learning.info/xAPI/verb/pressed" => "pressed",
      "http://future-learning.info/xAPI/verb/released" => "released",
      "http://id.tincanapi.com/verb/adjourned" => "adjourned",
      "http://id.tincanapi.com/verb/applauded" => "applauded",
      "http://id.tincanapi.com/verb/arranged" => "arranged",
      "http://id.tincanapi.com/verb/bookmarked" => "bookmarked",
      "http://id.tincanapi.com/verb/called" => "called",
      "http://id.tincanapi.com/verb/closed-sale" => "closed sale",
      "http://id.tincanapi.com/verb/created-opportunity" => "created opportunity",
      "http://id.tincanapi.com/verb/defined" => "defined",
      "http://id.tincanapi.com/verb/disabled" => "disabled",
      "http://id.tincanapi.com/verb/discarded" => "discarded",
      "http://id.tincanapi.com/verb/downloaded" => "downloaded",
      "http://id.tincanapi.com/verb/earned" => "earned",
      "http://id.tincanapi.com/verb/enabled" => "enabled",
      "http://id.tincanapi.com/verb/estimated-duration" => "estimated the duration",
      "http://id.tincanapi.com/verb/expected" => "expected",
      "http://id.tincanapi.com/verb/expired" => "expired",
      "http://id.tincanapi.com/verb/focused" => "focused",
      "http://id.tincanapi.com/verb/frame/entered" => "entered frame",
      "http://id.tincanapi.com/verb/frame/exited" => "exited frame",
      "http://id.tincanapi.com/verb/hired" => "hired",
      "http://id.tincanapi.com/verb/interviewed" => "interviewed",
      "http://id.tincanapi.com/verb/laughed" => "laughed",
      "http://id.tincanapi.com/verb/marked-unread" => "unread",
      "http://id.tincanapi.com/verb/mentioned" => "mentioned",
      "http://id.tincanapi.com/verb/mentored" => "mentored",
      "http://id.tincanapi.com/verb/paused" => "paused",
      "http://id.tincanapi.com/verb/performed-offline" => "performed",
      "http://id.tincanapi.com/verb/personalized" => "personalized",
      "http://id.tincanapi.com/verb/previewed" => "previewed",
      "http://id.tincanapi.com/verb/promoted" => "promoted",
      "http://id.tincanapi.com/verb/rated" => "rated",
      "http://id.tincanapi.com/verb/replied" => "replied",
      "http://id.tincanapi.com/verb/replied-to-tweet" => "replied to tweet",
      "http://id.tincanapi.com/verb/requested-attention" => "requested attention",
      "http://id.tincanapi.com/verb/retweeted" => "retweeted",
      "http://id.tincanapi.com/verb/reviewed" => "reviewed",
      "http://id.tincanapi.com/verb/secured" => "secured",
      "http://id.tincanapi.com/verb/selected" => "selected",
      "http://id.tincanapi.com/verb/skipped" => "skipped",
      "http://id.tincanapi.com/verb/talked-with" => "talked",
      "http://id.tincanapi.com/verb/terminated-employment-with" => "terminated employment with",
      "http://id.tincanapi.com/verb/tweeted" => "tweeted",
      "http://id.tincanapi.com/verb/unfocused" => "unfocused",
      "http://id.tincanapi.com/verb/unregistered" => "unregistered",
      "http://id.tincanapi.com/verb/viewed" => "viewed",
      "http://id.tincanapi.com/verb/voted-down" => "down voted",
      "http://id.tincanapi.com/verb/voted-up" => "up voted",
      "http://id.tincanapi.com/verb/was-assigned-job-title" => "was assigned job title",
      "http://id.tincanapi.com/verb/was-hired-by" => "was hired by",
      "http://risc-inc.com/annotator/verbs/annotated" => "annotated",
      "http://risc-inc.com/annotator/verbs/modified" => "modified annotation",
      "http://specification.openbadges.org/xapi/verbs/earned" => "earned an Open Badge",
      "http://www.digital-knowledge.co.jp/tincanapi/verbs/drew" => "drew",
      "http://www.tincanapi.co.uk/pages/verbs.html#cancelled_planned_learning" => "cancelled planned learning",
      "http://www.tincanapi.co.uk/pages/verbs.html#planned_learning" => "planned",
      "http://www.tincanapi.co.uk/verbs/enrolled_onto_learning_plan" => "enrolled onto learning plan",
      "http://www.tincanapi.co.uk/verbs/evaluated" => "evaluated",
      "https://brindlewaye.com/xAPITerms/verbs/added/" => "added",
      "https://brindlewaye.com/xAPITerms/verbs/loggedin/" => "log in",
      "https://brindlewaye.com/xAPITerms/verbs/loggedout/" => "log out",
      "https://brindlewaye.com/xAPITerms/verbs/ran/" => "ran",
      "https://brindlewaye.com/xAPITerms/verbs/removed/" => "removed",
      "https://brindlewaye.com/xAPITerms/verbs/reviewed/" => "reviewed",
      "https://brindlewaye.com/xAPITerms/verbs/walked/" => "walked"
    }

    # Initializes a new Verb instance.
    #
    # @param [string] verb_id The verb identifier. Must be a valid URL.
    def initialize(verb)
      raise VerbError, I18n.t("xapi_middleware.errors.missing_object", object: "verb") if verb.blank? || verb.nil?

      display = default_display(verb[:id])

      @id = verb[:id]
      @generic_display = display
      @display = {
        "en-US": display
      }

      # Add any other languages properties
      if verb[:display].is_a?(Hash) && verb[:display].any?
        verb[:display].each do |key, value|
          @display[key.to_sym] = value
        end
      end
    end

    # Generate the display value for "en-US".
    #
    # @param [String] verb The verb id.
    # @return [String] The generic display value.
    def default_display(verb_id)
      display = VERBS_LIST[verb_id]
      return verb_id.split("/")[-1] if display.nil?

      display
    end

    # Overrides the Hash class method.
    #
    # @return [Hash] The verb hash without the generic_display attribute.
    def to_hash
      {
        id: @id,
        display: @display
      }.compact
    end
  end
end
