class CreateRailsXapiStatements < ActiveRecord::Migration[7.1]
  def up
    create_table :rails_xapi_statements do |t|
      t.string :actor_id, null: false
      t.string :verb_id, null: false
      t.string :object_id, null: false
      t.datetime :timestamp, null: true
      t.datetime :created_at, null: false
    end

    add_index :rails_xapi_statements, :actor_id
    add_index :rails_xapi_statements, :verb_id
    add_index :rails_xapi_statements, :object_id
  end

  def down
    drop_table :rails_xapi_statements
  end
end
