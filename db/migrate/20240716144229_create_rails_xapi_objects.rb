class CreateRailsXapiObjects < ActiveRecord::Migration[7.1]
  def up
    create_table :rails_xapi_objects, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :object_type, null: false
      t.bigint :statement_id, null: true
    end

    add_index :rails_xapi_objects, :id, unique: true
    add_index :rails_xapi_objects, :statement_id
  end

  def down
    drop_table :rails_xapi_objects
  end
end
