class CreateXapiMiddlewareStatements < ActiveRecord::Migration[7.1]
  def change
    create_table :xapi_middleware_statements do |t|
      t.string :actor_name
      t.string :verb_id
      t.string :object_identifier
      t.text :statement_json

      t.timestamps
    end
  end
end
