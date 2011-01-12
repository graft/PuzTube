# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110112070254) do

  create_table "assets", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "workspace_id"
  end

  create_table "chats", :force => true do |t|
    t.string   "user"
    t.string   "chat_id"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "puzzles", :force => true do |t|
    t.string   "name"
    t.string   "hint"
    t.string   "captain"
    t.string   "answer"
    t.boolean  "meta"
    t.integer  "round_id"
    t.string   "status"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "wrong_answer"
  end

  create_table "rounds", :force => true do |t|
    t.string   "name"
    t.string   "hint"
    t.string   "captain"
    t.string   "answer"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "image"
    t.string   "info"
    t.string   "activity"
    t.datetime "lastactive"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.boolean  "team_captain"
    t.string   "options"
  end

  create_table "workspaces", :force => true do |t|
    t.string   "content"
    t.string   "thread_type"
    t.integer  "thread_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "priority"
    t.string   "title"
  end

end
