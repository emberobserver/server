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

ActiveRecord::Schema.define(version: 20150201222843) do

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "packages", force: :cascade do |t|
    t.string   "name"
    t.string   "npmjs_url"
    t.string   "github_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "package_id"
    t.string   "version"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "reviews", ["package_id"], name: "index_reviews_on_package_id"

end
