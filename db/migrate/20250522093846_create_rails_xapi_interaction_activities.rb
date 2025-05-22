class CreateRailsXapiInteractionActivities < ActiveRecord::Migration[7.2]
  def change
    create_table :rails_xapi_interaction_activities do |t|
      t.string :interaction_type, null: false
      t.text :correct_responses_pattern, null: true
      t.bigint :activity_definition_id, null: false
    end

    add_index :rails_xapi_interaction_activities, :activity_definition_id
  end

  def down
    drop_table :rails_xapi_interaction_activities
  end
end
