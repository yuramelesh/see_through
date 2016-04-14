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

ActiveRecord::Schema.define(version: 20160414162947) do

  create_table "commentors", force: :cascade do |t|
    t.integer "pull_request_id"
    t.string  "user_id"
  end

  create_table "daily_reports", force: :cascade do |t|
    t.string "user_name"
    t.string "sent_at"
  end

  create_table "pull_requests", force: :cascade do |t|
    t.text    "repo"
    t.string  "title"
    t.string  "pr_id"
    t.string  "author"
    t.boolean "merged"
    t.boolean "mergeable"
    t.string  "mergeable_state"
    t.string  "state"
    t.string  "pr_commenters"
    t.string  "committer"
    t.string  "labels"
    t.string  "created_at"
    t.string  "updated_at"
    t.string  "added_to_database"
  end

  create_table "repositories", id: false, force: :cascade do |t|
    t.text "repository_name"
  end

  create_table "tabla", force: :cascade do |t|
    t.string   "name"
    t.string   "title",      null: false
    t.string   "iddd",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string  "user_login"
    t.string  "user_email"
    t.string  "git_email"
    t.integer "git_hub_id"
    t.string  "notify_at"
    t.boolean "enable"
  end

end
