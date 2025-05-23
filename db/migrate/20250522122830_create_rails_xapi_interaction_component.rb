class CreateRailsXapiInteractionComponent < ActiveRecord::Migration[7.2]
  def change
    create_table :rails_xapi_interaction_components do |t|
      t.string :component_type, null: false
      t.string :component_id, null: false
      t.text :description, null: true
      t.bigint :interaction_activity_id, null: false
    end

    add_index :rails_xapi_interaction_components, :interaction_activity_id
  end

  def down
    drop_table :rails_xapi_interaction_components
  end
end
