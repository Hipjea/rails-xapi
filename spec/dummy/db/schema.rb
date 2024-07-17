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

ActiveRecord::Schema[7.1].define(version: 2024_07_16_144230) do
  create_table "xapi_middleware_actors", force: :cascade do |t|
    t.string "object_type"
    t.string "name"
    t.string "mbox"
    t.string "mbox_sha1sum"
    t.string "openid"
    t.string "account"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "xapi_middleware_objects", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "type"
    t.text "more_info"
    t.text "extensions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "xapi_middleware_statements", force: :cascade do |t|
    t.integer "actor_id"
    t.integer "verb_id"
    t.integer "object_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_xapi_middleware_statements_on_actor_id"
    t.index ["object_id"], name: "index_xapi_middleware_statements_on_object_id"
    t.index ["verb_id"], name: "index_xapi_middleware_statements_on_verb_id"
  end

  create_table "xapi_middleware_verbs", force: :cascade do |t|
    t.string "display"
    t.text "display_full"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "xapi_middleware_statements", "actors"
  add_foreign_key "xapi_middleware_statements", "objects"
  add_foreign_key "xapi_middleware_statements", "verbs"
end
