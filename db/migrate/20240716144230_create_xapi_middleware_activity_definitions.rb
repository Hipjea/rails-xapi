class CreateXapiMiddlewareActivityDefinitions < ActiveRecord::Migration[7.1]
  def up
    create_table :xapi_middleware_activity_definitions do |t|
      t.string :name, null: true
      t.text :description, null: true
      t.string :activity_type, null: true
      t.text :more_info, null: true
      t.string :object_id, null: false
    end

    add_index :xapi_middleware_activity_definitions, :object_id
  end

  def down
    drop_table :xapi_middleware_activity_definitions
  end
end
