class CreateRailsXapiExtensions < ActiveRecord::Migration[7.1]
  def up
    create_table :rails_xapi_extensions do |t|
      t.string :iri, null: false
      t.text :value, null: false
      t.references :extendable, polymorphic: true
    end
  end

  def down
    drop_table :rails_xapi_extensions
  end
end
