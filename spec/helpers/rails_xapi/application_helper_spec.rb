# spec/models/result_spec.rb

require "rails_helper"

describe RailsXapi::ApplicationHelper, type: :helper do
  it "should output the duration in minutes" do
    result = RailsXapi::Result.new(
      duration: "PT1H00M01.00S",
      statement: RailsXapi::Statement.new(@default_statement)
    )

    expect(duration_to_minutes(result.duration)).to eq("60.02")
  end
end

# == Schema Information
#
# Table name: rails_xapi_results
#
#  id           :integer          not null, primary key
#  completion   :boolean          default(FALSE)
#  duration     :string
#  response     :text
#  score_max    :integer
#  score_min    :integer
#  score_raw    :integer
#  score_scaled :decimal(3, 2)
#  success      :boolean          default(FALSE)
#  statement_id :bigint           not null
#
# Indexes
#
#  index_rails_xapi_results_on_statement_id  (statement_id)
#
