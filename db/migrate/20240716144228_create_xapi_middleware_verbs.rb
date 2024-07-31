class CreateXapiMiddlewareVerbs < ActiveRecord::Migration[7.1]
  def up
    create_table :xapi_middleware_verbs, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :display, null: true
    end

    add_index :xapi_middleware_verbs, :id, unique: true
  end

  def down
    drop_table :xapi_middleware_verbs
  end
end
