class DbRollup < ActiveRecord::Migration
  def change

    create_table "categories", force: :cascade do |t|
      t.string   "name"
      t.datetime "created_at",  null: false
      t.datetime "updated_at",  null: false
      t.text     "description"
    end

    create_table "category_packages", force: :cascade do |t|
      t.integer  "category_id"
      t.integer  "package_id"
      t.datetime "created_at",  null: false
      t.datetime "updated_at",  null: false
    end

    add_index "category_packages", ["category_id"], name: "index_category_packages_on_category_id"
    add_index "category_packages", ["package_id"], name: "index_category_packages_on_package_id"

    create_table "evaluations", force: :cascade do |t|
      t.integer  "metric_id"
      t.integer  "review_id"
      t.float    "score"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index "evaluations", ["metric_id"], name: "index_evaluations_on_metric_id"
    add_index "evaluations", ["review_id"], name: "index_evaluations_on_review_id"

    create_table "metrics", force: :cascade do |t|
      t.string   "name"
      t.string   "description"
      t.text     "details"
      t.datetime "created_at",  null: false
      t.datetime "updated_at",  null: false
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
    end

    create_table "package_maintainers", id: false, force: :cascade do |t|
      t.integer "package_id"
      t.integer "npm_user_id"
    end

    create_table "package_npm_keywords", id: false, force: :cascade do |t|
      t.integer "package_id"
      t.integer "npm_keyword_id"
    end

    create_table "packages", force: :cascade do |t|
      t.string   "name"
      t.string   "repository_url"
      t.datetime "created_at",          null: false
      t.datetime "updated_at",          null: false
      t.string   "latest_version"
      t.string   "description"
      t.string   "license"
      t.integer  "author_id"
      t.datetime "latest_version_date"
    end

    create_table "reviews", force: :cascade do |t|
      t.integer  "package_id"
      t.string   "version"
      t.text     "body"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    add_index "reviews", ["package_id"], name: "index_reviews_on_package_id"

    create_table "users", force: :cascade do |t|
      t.string   "email"
      t.string   "password_digest"
      t.string   "auth_token"
      t.datetime "created_at",      null: false
      t.datetime "updated_at",      null: false
    end

  end
end
