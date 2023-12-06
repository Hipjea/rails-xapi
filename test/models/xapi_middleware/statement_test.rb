require "test_helper"

module XapiMiddleware
  class StatementTest < ActiveSupport::TestCase
    def setup
      @pre_statement = XapiMiddleware::Statement.new(
        verb_id: "http://example.com/verb",
        object: {
          id: "http://example.com/object"
        },
        actor: {
          name: "Actor 1",
          mbox: "mailto:actor1@localhost.com",
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

      @statement = XapiMiddleware::Statement.new(
        verb_id: "http://example.com/verb",
        object: {
          object_type: "SubStatement",
          actor: {
            objectType: "Agent",
            name: "Example Admin",
            mbox: "mailto:admin@example.adlnet.gov"
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

      p"*"*90
      p JSON.parse(@statement.statement_json)["object"]
      p"*"*90
    end

    test "valid statement" do
      assert @statement.valid?, "Statement should be valid"
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
#  id                :integer          not null, primary key
#  actor_name        :string
#  object_identifier :string
#  object_type       :string
#  statement_json    :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  verb_id           :string
#
