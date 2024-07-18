class CreateXapiMiddlewareExtensions < ActiveRecord::Migration[7.1]
  def up
    create_table :xapi_middleware_extensions do |t|
      t.string :iri, null: false
      t.text :value, null: false
      t.references :extendable, polymorphic: true
    end
  end

  def down
    drop_table :xapi_middleware_extensions
  end
end
