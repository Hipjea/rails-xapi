class CreateXapiMiddlewareExtensions < ActiveRecord::Migration[7.1]
  def up
    create_table :xapi_middleware_extensions do |t|
      t.string :iri, null: false
      t.text :value, null: false
      t.integer :definition_id, null: true
      t.integer :result_id, null: true
    end

    add_index :xapi_middleware_extensions, :definition_id
    add_index :xapi_middleware_extensions, :result_id
  end

  def down
    drop_table :xapi_middleware_extensions
  end
end
