# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150316003329) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addon_downloads", force: :cascade do |t|
    t.integer "addon_id"
    t.date    "date"
    t.integer "downloads"
  end

  add_index "addon_downloads", ["addon_id"], name: "index_addon_downloads_on_addon_id", using: :btree

  create_table "addon_github_contributors", force: :cascade do |t|
    t.integer "addon_id"
    t.integer "github_user_id"
  end

  add_index "addon_github_contributors", ["addon_id"], name: "index_addon_github_contributors_on_addon_id", using: :btree
  add_index "addon_github_contributors", ["github_user_id"], name: "index_addon_github_contributors_on_github_user_id", using: :btree

  create_table "addon_maintainers", id: false, force: :cascade do |t|
    t.integer "addon_id"
    t.integer "npm_user_id"
  end

  create_table "addon_npm_keywords", id: false, force: :cascade do |t|
    t.integer "addon_id"
    t.integer "npm_keyword_id"
  end

  create_table "addon_versions", force: :cascade do |t|
    t.integer  "addon_id"
    t.string   "version"
    t.datetime "released"
    t.string   "addon_name"
  end

  create_table "addons", force: :cascade do |t|
    t.string   "name"
    t.string   "repository_url"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "latest_version"
    t.string   "description"
    t.string   "license"
    t.integer  "author_id"
    t.datetime "latest_version_date"
    t.boolean  "deprecated",              default: false
    t.text     "note"
    t.boolean  "official",                default: false
    t.boolean  "cli_dependency",          default: false
    t.boolean  "hidden",                  default: false
    t.string   "github_user"
    t.string   "github_repo"
    t.boolean  "has_invalid_github_repo", default: false
    t.text     "rendered_note"
    t.integer  "last_month_downloads"
    t.boolean  "is_top_downloaded",       default: false
    t.boolean  "is_top_starred",          default: false
    t.integer  "score"
    t.datetime "published_date"
    t.datetime "last_seen_in_npm"
    t.boolean  "is_wip"
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "description"
    t.integer  "parent_id"
    t.integer  "position"
  end

  create_table "category_addons", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "addon_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "category_addons", ["addon_id"], name: "index_category_addons_on_addon_id", using: :btree
  add_index "category_addons", ["category_id"], name: "index_category_addons_on_category_id", using: :btree

  create_table "github_stats", force: :cascade do |t|
    t.integer  "addon_id"
    t.integer  "open_issues"
    t.integer  "contributors"
    t.integer  "commits"
    t.integer  "forks"
    t.datetime "first_commit_date"
    t.string   "first_commit_sha"
    t.datetime "latest_commit_date"
    t.string   "latest_commit_sha"
    t.integer  "stars"
    t.datetime "penultimate_commit_date"
    t.string   "penultimate_commit_sha"
    t.datetime "repo_created_date"
  end

  add_index "github_stats", ["addon_id"], name: "index_github_stats_on_addon_id", using: :btree

  create_table "github_users", force: :cascade do |t|
    t.string "login"
    t.string "avatar_url"
  end

  create_table "npm_keywords", force: :cascade do |t|
    t.string   "keyword"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "npm_users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "gravatar"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "has_tests"
    t.integer  "has_readme"
    t.integer  "is_more_than_empty_addon"
    t.text     "review"
    t.integer  "addon_version_id",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_open_source"
    t.integer  "has_build"
    t.string   "addon_name"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "auth_token"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_foreign_key "addon_downloads", "addons"
  add_foreign_key "github_stats", "addons"
end
