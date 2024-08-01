# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_07_16_144235) do
  create_table "xapi_middleware_accounts", force: :cascade do |t|
    t.string "name", null: false
    t.string "home_page", null: false
    t.bigint "actor_id", null: false
    t.index ["actor_id"], name: "index_xapi_middleware_accounts_on_actor_id"
  end

  create_table "xapi_middleware_activity_definitions", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "activity_type"
    t.text "more_info"
    t.string "object_id", null: false
    t.index ["object_id"], name: "index_xapi_middleware_activity_definitions_on_object_id"
  end

  create_table "xapi_middleware_actors", force: :cascade do |t|
    t.string "object_type"
    t.string "name"
    t.string "mbox"
    t.string "mbox_sha1sum"
    t.string "openid"
    t.datetime "created_at", null: false
  end

  create_table "xapi_middleware_context_activities", force: :cascade do |t|
    t.string "activity_type", null: false
    t.bigint "context_id", null: false
    t.string "object_id", null: false
    t.index ["context_id"], name: "index_xapi_middleware_context_activities_on_context_id"
    t.index ["object_id"], name: "index_xapi_middleware_context_activities_on_object_id"
  end

  create_table "xapi_middleware_contexts", force: :cascade do |t|
    t.string "registration"
    t.bigint "instructor_id"
    t.bigint "team_id"
    t.string "revision"
    t.string "platform"
    t.string "language"
    t.bigint "statement_ref"
    t.bigint "statement_id", null: false
    t.index ["instructor_id"], name: "index_xapi_middleware_contexts_on_instructor_id"
    t.index ["statement_id"], name: "index_xapi_middleware_contexts_on_statement_id"
    t.index ["statement_ref"], name: "index_xapi_middleware_contexts_on_statement_ref"
    t.index ["team_id"], name: "index_xapi_middleware_contexts_on_team_id"
  end

  create_table "xapi_middleware_extensions", force: :cascade do |t|
    t.string "iri", null: false
    t.text "value", null: false
    t.string "extendable_type"
    t.integer "extendable_id"
    t.index ["extendable_type", "extendable_id"], name: "index_xapi_middleware_extensions_on_extendable"
  end

  create_table "xapi_middleware_objects", id: :string, force: :cascade do |t|
    t.string "object_type", null: false
    t.bigint "statement_id"
    t.index ["id"], name: "index_xapi_middleware_objects_on_id", unique: true
    t.index ["statement_id"], name: "index_xapi_middleware_objects_on_statement_id"
  end

  create_table "xapi_middleware_results", force: :cascade do |t|
    t.decimal "score_scaled", precision: 3, scale: 2
    t.integer "score_raw"
    t.integer "score_min"
    t.integer "score_max"
    t.boolean "success", default: false
    t.boolean "completion", default: false
    t.text "response"
    t.string "duration"
    t.bigint "statement_id", null: false
    t.index ["statement_id"], name: "index_xapi_middleware_results_on_statement_id"
  end

  create_table "xapi_middleware_statements", force: :cascade do |t|
    t.string "actor_id", null: false
    t.string "verb_id", null: false
    t.string "object_id", null: false
    t.datetime "timestamp"
    t.datetime "created_at", null: false
    t.index ["actor_id"], name: "index_xapi_middleware_statements_on_actor_id"
    t.index ["object_id"], name: "index_xapi_middleware_statements_on_object_id"
    t.index ["verb_id"], name: "index_xapi_middleware_statements_on_verb_id"
  end

  create_table "xapi_middleware_verbs", id: :string, force: :cascade do |t|
    t.string "display"
    t.index ["id"], name: "index_xapi_middleware_verbs_on_id", unique: true
  end

end
