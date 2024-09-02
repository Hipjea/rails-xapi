class CreateRailsXapiVerbs < ActiveRecord::Migration[7.1]
  def up
    create_table :rails_xapi_verbs, id: false do |t|
      t.string :id, null: false, primary_key: true
      t.string :display, null: true
    end

    add_index :rails_xapi_verbs, :id, unique: true
  end

  def down
    drop_table :rails_xapi_verbs
  end
end
