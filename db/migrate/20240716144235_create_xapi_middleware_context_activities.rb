class CreateXapiMiddlewareContextActivities < ActiveRecord::Migration[7.1]
  def up
    create_table :xapi_middleware_context_activities do |t|
      t.string :activity_type, null: false
      t.bigint :context_id, null: false
      t.string :object_id, null: false
    end

    add_index :xapi_middleware_context_activities, :context_id
    add_index :xapi_middleware_context_activities, :object_id
  end

  def down
    drop_table :xapi_middleware_context_activities
  end
end
