class CreateXapiMiddlewareContexts < ActiveRecord::Migration[7.1]
  def up
    create_table :xapi_middleware_contexts do |t|
      t.string :registration, null: true
      t.bigint :instructor_id, null: true
      t.bigint :team_id, null: true
      t.string :revision, null: true
      t.string :platform, null: true
      t.string :language, null: true
      t.bigint :statement_ref, null: true
      t.bigint :statement_id, null: false
    end

    add_index :xapi_middleware_contexts, :instructor_id
    add_index :xapi_middleware_contexts, :team_id
    add_index :xapi_middleware_contexts, :statement_ref
    add_index :xapi_middleware_contexts, :statement_id
  end

  def down
    drop_table :xapi_middleware_contexts
  end
end
