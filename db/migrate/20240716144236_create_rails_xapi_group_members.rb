class CreateRailsXapiGroupMembers < ActiveRecord::Migration[7.1]
  def up
    create_table :rails_xapi_group_members do |t|
      t.bigint :group_id, null: false
      t.bigint :actor_id, null: false
      t.datetime :created_at, null: false
    end

    add_index :rails_xapi_group_members, :group_id
    add_index :rails_xapi_group_members, :actor_id
  end

  def down
    drop_table :rails_xapi_group_members
  end
end
