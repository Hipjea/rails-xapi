class CreateXapiMiddlewareObjects < ActiveRecord::Migration[7.1]
  def up
    create_table :xapi_middleware_objects, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :object_type, null: false
    end

    add_index :xapi_middleware_objects, :id, unique: true
  end

  def down
    drop_table :xapi_middleware_objects
  end
end
