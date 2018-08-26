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

ActiveRecord::Schema.define(version: 20180909232841) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addon_downloads", id: :serial, force: :cascade do |t|
    t.integer "addon_id"
    t.date "date"
    t.integer "downloads"
    t.index ["addon_id"], name: "index_addon_downloads_on_addon_id"
  end

  create_table "addon_github_contributors", id: :serial, force: :cascade do |t|
    t.integer "addon_id"
    t.integer "github_user_id"
    t.index ["addon_id"], name: "index_addon_github_contributors_on_addon_id"
    t.index ["github_user_id"], name: "index_addon_github_contributors_on_github_user_id"
  end

  create_table "addon_maintainers", id: false, force: :cascade do |t|
    t.integer "addon_id"
    t.integer "npm_maintainer_id"
    t.index ["addon_id", "npm_maintainer_id"], name: "index_addon_maintainers_on_addon_id_and_npm_maintainer_id"
    t.index ["addon_id"], name: "index_addon_maintainers_on_addon_id"
    t.index ["npm_maintainer_id"], name: "index_addon_maintainers_on_npm_maintainer_id"
  end

  create_table "addon_npm_keywords", id: false, force: :cascade do |t|
    t.integer "addon_id"
    t.integer "npm_keyword_id"
    t.index ["addon_id"], name: "index_addon_npm_keywords_on_addon_id"
    t.index ["npm_keyword_id"], name: "index_addon_npm_keywords_on_npm_keyword_id"
  end

  create_table "addon_sizes", force: :cascade do |t|
    t.bigint "addon_version_id"
    t.integer "app_js_size"
    t.integer "app_css_size"
    t.integer "vendor_js_size"
    t.integer "vendor_css_size"
    t.index ["addon_version_id"], name: "index_addon_sizes_on_addon_version_id"
  end

  create_table "addon_version_compatibilities", id: :serial, force: :cascade do |t|
    t.integer "addon_version_id"
    t.string "package"
    t.string "version"
    t.index ["addon_version_id"], name: "index_addon_version_compatibilities_on_addon_version_id"
  end

  create_table "addon_version_dependencies", id: :serial, force: :cascade do |t|
    t.string "package"
    t.string "version"
    t.string "dependency_type"
    t.integer "addon_version_id"
    t.index ["addon_version_id"], name: "index_addon_version_dependencies_on_addon_version_id"
    t.index ["package", "version"], name: "index_addon_version_dependencies_on_package_and_version"
    t.index ["package"], name: "index_addon_version_dependencies_on_package"
  end

  create_table "addon_versions", id: :serial, force: :cascade do |t|
    t.integer "addon_id"
    t.string "version"
    t.datetime "released"
    t.string "addon_name"
    t.string "ember_cli_version"
    t.index ["addon_id"], name: "index_addon_versions_on_addon_id"
  end

  create_table "addons", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "repository_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "latest_version"
    t.string "description"
    t.string "license"
    t.integer "npm_author_id"
    t.datetime "latest_version_date"
    t.boolean "deprecated", default: false
    t.text "note"
    t.boolean "official", default: false
    t.boolean "cli_dependency", default: false
    t.boolean "hidden", default: false
    t.string "github_user"
    t.string "github_repo"
    t.boolean "has_invalid_github_repo", default: false
    t.text "rendered_note"
    t.integer "last_month_downloads"
    t.boolean "is_top_downloaded", default: false
    t.boolean "is_top_starred", default: false
    t.integer "score"
    t.datetime "published_date"
    t.datetime "last_seen_in_npm"
    t.boolean "is_wip", default: false, null: false
    t.string "demo_url"
    t.integer "ranking"
    t.integer "latest_addon_version_id"
    t.datetime "package_info_last_updated_at"
    t.datetime "repo_info_last_updated_at"
    t.bigint "latest_review_id"
    t.index ["latest_addon_version_id"], name: "index_addons_on_latest_addon_version_id"
    t.index ["latest_review_id"], name: "index_addons_on_latest_review_id"
    t.index ["npm_author_id"], name: "index_addons_on_npm_author_id"
  end

  create_table "build_servers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "parent_id"
    t.integer "position"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "category_addons", id: :serial, force: :cascade do |t|
    t.integer "category_id"
    t.integer "addon_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addon_id"], name: "index_category_addons_on_addon_id"
    t.index ["category_id"], name: "index_category_addons_on_category_id"
  end

  create_table "ember_version_compatibilities", id: :serial, force: :cascade do |t|
    t.integer "test_result_id"
    t.string "ember_version"
    t.boolean "compatible"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_result_id"], name: "index_ember_version_compatibilities_on_test_result_id"
  end

  create_table "github_stats", id: :serial, force: :cascade do |t|
    t.integer "addon_id"
    t.integer "open_issues"
    t.integer "contributors"
    t.integer "commits"
    t.integer "forks"
    t.datetime "first_commit_date"
    t.string "first_commit_sha"
    t.datetime "latest_commit_date"
    t.string "latest_commit_sha"
    t.integer "stars"
    t.datetime "penultimate_commit_date"
    t.string "penultimate_commit_sha"
    t.datetime "repo_created_date"
    t.index ["addon_id"], name: "index_github_stats_on_addon_id"
  end

  create_table "github_users", id: :serial, force: :cascade do |t|
    t.string "login"
    t.string "avatar_url"
  end

  create_table "latest_versions", id: :serial, force: :cascade do |t|
    t.string "package"
    t.string "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "npm_authors", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "npm_keywords", id: :serial, force: :cascade do |t|
    t.string "keyword"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "npm_maintainers", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "gravatar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pending_builds", id: :serial, force: :cascade do |t|
    t.integer "addon_version_id"
    t.datetime "build_assigned_at"
    t.integer "build_server_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "canary", default: false, null: false
    t.index ["addon_version_id"], name: "index_pending_builds_on_addon_version_id"
    t.index ["build_server_id"], name: "index_pending_builds_on_build_server_id"
  end

  create_table "readmes", id: :serial, force: :cascade do |t|
    t.text "contents"
    t.integer "addon_id"
    t.index ["addon_id"], name: "index_readmes_on_addon_id"
  end

  create_table "reviews", id: :serial, force: :cascade do |t|
    t.integer "has_tests"
    t.integer "has_readme"
    t.integer "is_more_than_empty_addon"
    t.text "review"
    t.integer "addon_version_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "is_open_source"
    t.integer "has_build"
    t.string "addon_name"
    t.index ["addon_version_id"], name: "index_reviews_on_addon_version_id"
  end

  create_table "test_results", id: :serial, force: :cascade do |t|
    t.integer "addon_version_id"
    t.boolean "succeeded"
    t.string "status_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "canary", default: false, null: false
    t.integer "build_server_id"
    t.string "semver_string"
    t.text "output"
    t.index ["addon_version_id"], name: "index_test_results_on_addon_version_id"
    t.index ["build_server_id"], name: "index_test_results_on_build_server_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "auth_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "addon_downloads", "addons"
  add_foreign_key "addon_sizes", "addon_versions"
  add_foreign_key "addon_version_compatibilities", "addon_versions"
  add_foreign_key "addons", "addon_versions", column: "latest_addon_version_id"
  add_foreign_key "addons", "reviews", column: "latest_review_id"
  add_foreign_key "ember_version_compatibilities", "test_results"
  add_foreign_key "github_stats", "addons"
  add_foreign_key "pending_builds", "addon_versions"
  add_foreign_key "pending_builds", "build_servers"
  add_foreign_key "test_results", "addon_versions"
  add_foreign_key "test_results", "build_servers"

  create_view "readmes_indexed_for_fts", materialized: true,  sql_definition: <<-SQL
      SELECT readmes.id,
      readmes.contents,
      to_tsvector('english'::regconfig, readmes.contents) AS contents_tsvector,
      addons.id AS addon_id
     FROM (readmes
       JOIN addons ON ((readmes.addon_id = addons.id)))
    WHERE ((addons.hidden = false) AND (addons.has_invalid_github_repo = false));
  SQL

  add_index "readmes_indexed_for_fts", ["contents_tsvector"], name: "gin_index_on_contents", using: :gin
  add_index "readmes_indexed_for_fts", ["id"], name: "unique_index_on_id", unique: true

end
