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

ActiveRecord::Schema[8.1].define(version: 2026_11_08_153002) do
  create_table "choices", force: :cascade do |t|
    t.text "body"
    t.boolean "correct"
    t.text "feedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "question_id", null: false
    t.index ["question_id"], name: "index_choices_on_question_id"
  end

  create_table "course_memberships", force: :cascade do |t|
    t.integer "course_id", null: false
    t.integer "user_id", null: false
    t.string "role", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "user_id"], name: "index_course_memberships_on_course_id_and_user_id", unique: true
    t.index ["course_id"], name: "index_course_memberships_on_course_id"
    t.index ["user_id"], name: "index_course_memberships_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "question_sets", force: :cascade do |t|
    t.string "title", null: false
    t.integer "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_question_sets_on_owner_id"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "number"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "question_set_id"
    t.index ["question_set_id"], name: "index_questions_on_question_set_id"
  end

  create_table "session_participants", id: false, force: :cascade do |t|
    t.integer "session_id", null: false
    t.integer "user_id", null: false
    t.index ["session_id", "user_id"], name: "index_session_participants_on_session_id_and_user_id", unique: true
    t.index ["user_id"], name: "index_session_participants_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "question_set_id", null: false
    t.integer "host_id", null: false
    t.string "code", null: false
    t.string "status", default: "active", null: false
    t.json "summary", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_sessions_on_code", unique: true
    t.index ["host_id"], name: "index_sessions_on_host_id"
    t.index ["question_set_id"], name: "index_sessions_on_question_set_id"
    t.index ["status"], name: "index_sessions_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "email"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
  end

  add_foreign_key "choices", "questions"
  add_foreign_key "course_memberships", "courses"
  add_foreign_key "course_memberships", "users"
  add_foreign_key "questions", "question_sets"
end
