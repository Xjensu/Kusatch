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

ActiveRecord::Schema[8.0].define(version: 2025_04_19_173026) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "blogs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "description"
    t.string "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_blogs_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "blog_id", null: false
    t.bigint "user_id", null: false
    t.bigint "parent_comment_id"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blog_id"], name: "index_comments_on_blog_id"
    t.index ["parent_comment_id"], name: "index_comments_on_parent_comment_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token"
    t.string "hashed_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_refresh_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.boolean "is_moderator", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "blogs", "users"
  add_foreign_key "comments", "blogs"
  add_foreign_key "comments", "comments", column: "parent_comment_id"
  add_foreign_key "comments", "users"
  add_foreign_key "refresh_tokens", "users"
end
