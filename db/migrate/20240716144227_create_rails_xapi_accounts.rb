class CreateRailsXapiAccounts < ActiveRecord::Migration[7.1]
  def up
    create_table :rails_xapi_accounts do |t|
      t.string :name, null: false
      t.string :home_page, null: false
      t.bigint :actor_id, null: false
    end

    add_index :rails_xapi_accounts, :actor_id
  end

  def down
    drop_table :rails_xapi_accounts
  end
end
