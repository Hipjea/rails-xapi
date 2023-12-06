require "test_helper"

module XapiMiddleware
  class StatementTest < ActiveSupport::TestCase
    def setup
      # Create a statement with an Activity object (by default)
      @statement = XapiMiddleware::Statement.new(
        verb: {
          id: "http://example.com/verb"
        },
        object: {
          id: "http://example.com/object"
        },
        actor: {
          name: "Actor 1",
          mbox_sha1sum: "sha1:d35132bd0bfc15ada6f5229002b5288d94a46f52",
          account: {
            name: "Actor#1"
          },
          openid: "http://example.com/object/Actor#1" 
        },
        result: { 
          response: "The actor 1 answered",
          success: true,
          score_raw: 50,
          score_min: 0,
          score_max: 100
        }
      )

      # Create a statement with a SubStatement object
      @substatement_statement = XapiMiddleware::Statement.new(
        verb: {
          id: "http://example.com/verb",
          display: {
            "en-US": "voided",
            fr: "vidé",
            "gb": "voided"
          }
        },
        object: {
          object_type: "SubStatement",
          actor: {
            objectType: "Agent",
            name: "Example Admin",
            mbox: "mailto:admin@example.com"
          },
          verb: {
            id: "http://adlnet.gov/expapi/verbs/voided",
            display: {
              "en-US": "voided"
            }
          },
          object: {
            objectType: "StatementRef",
            id: "e05aa883-acaf-40ad-bf54-02c8ce485fb0"
          }
        },
        actor: {
          name: "ÿøhnNÿ DœE",
          mbox: "mailto:yohnny.doe@localhost.com",
          account: {
            name: "JohnnyAccount#1"
          },
          openid: "http://example.com/object/JohnnyAccount#1" 
        },
        result: { 
          response: "The user answered",
          success: true,
          score_raw: 50,
          score_min: 0,
          score_max: 100
        }
      )
    end

    test "valid statement" do
      assert @statement.valid?, "Activity statement should be valid"
      assert @substatement_statement.valid?, "Substatement statement should be valid"

      pp JSON.parse(@statement.statement_json)
    end

    test "invalid statement without verb_id" do
      @statement.verb_id = nil
      assert_not @statement.valid?, "Statement should be invalid without verb_id"
    end

    test "output logs when configuration allows" do
      XapiMiddleware.configuration.output_xapi_logs = true
      assert_not @statement.output.nil?
    end

    test "output does not log when configuration disallows" do
      XapiMiddleware.configuration.output_xapi_logs = false
      assert_nothing_logged { @statement.output }
    end

    private

      def assert_nothing_logged
        assert_logs(:info, nil) do
          yield
        end
      end

      def assert_logs(level, message)
        original_logger = Rails.logger
        log_output = StringIO.new
        Rails.logger = Logger.new(log_output)

        yield

        log_output.rewind
        logs = log_output.read

        assert_match(/#{level}: #{message}/, logs) if message
        assert_empty logs unless message
      ensure
        Rails.logger = original_logger
      end
  end
end

# == Schema Information
#
# Table name: xapi_middleware_statements
#
#  id                     :integer          not null, primary key
#  actor_account_homepage :string
#  actor_account_name     :string
#  actor_mbox             :string
#  actor_name             :string
#  actor_openid           :string
#  actor_sha1sum          :string
#  object_identifier      :string
#  object_type            :string
#  statement_json         :text
#  verb_display           :string
#  verb_display_full      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  verb_id                :string
#
