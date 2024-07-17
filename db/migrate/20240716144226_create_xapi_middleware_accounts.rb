class CreateXapiMiddlewareAccounts < ActiveRecord::Migration[7.1]
  def up
    create_table :xapi_middleware_accounts do |t|
      t.string :name, null: false
      t.string :home_page, null: false
    end
  end

  def down
    drop_table :xapi_middleware_accounts
  end
end
