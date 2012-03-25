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

ActiveRecord::Schema.define(:version => 20100329002635) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.string   "activity_type"
    t.integer  "activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bloggers", :force => true do |t|
    t.integer  "poster_id",   :null => false
    t.string   "poster_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bloggers", ["poster_id", "poster_type"], :name => "index_bloggers_on_poster_id_and_poster_type", :unique => true

  create_table "brain_busters", :force => true do |t|
    t.string "question"
    t.string "answer"
  end

  create_table "comments", :force => true do |t|
    t.integer  "post_id",     :null => false
    t.integer  "poster_id",   :null => false
    t.string   "poster_type", :null => false
    t.text     "content",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text     "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.integer  "friend_id",   :null => false
    t.datetime "created_at"
    t.datetime "accepted_at"
  end

  create_table "interests_users", :id => false, :force => true do |t|
    t.integer "interest_id"
    t.integer "user_id"
  end

  add_index "interests_users", ["interest_id"], :name => "index_interests_users_on_interest_id"
  add_index "interests_users", ["user_id"], :name => "index_interests_users_on_user_id"

  create_table "locations", :force => true do |t|
  end

  create_table "messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.boolean  "sender_deleted",    :default => false
    t.boolean  "recipient_deleted", :default => false
    t.string   "subject"
    t.text     "body"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.string   "permalink",                             :null => false
    t.integer  "poster_id",                             :null => false
    t.string   "poster_type",                           :null => false
    t.string   "title",                                 :null => false
    t.text     "content",                               :null => false
    t.boolean  "published",          :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "front_page"
    t.boolean  "is_question",        :default => false
    t.datetime "published_at"
    t.boolean  "trackbacks_sent",    :default => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
  end

  create_table "requests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "recipient_id"
    t.string   "request_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "sent_at"
    t.boolean  "read",         :default => false
    t.text     "message"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
    t.string "object_type"
  end

  create_table "user_comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.string   "comment",                        :default => ""
    t.datetime "created_at",                                     :null => false
    t.integer  "commentable_id",                 :default => 0,  :null => false
    t.string   "commentable_type", :limit => 15, :default => "", :null => false
    t.integer  "user_id",                        :default => 0,  :null => false
  end

  add_index "user_comments", ["user_id"], :name => "fk_comments_user"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "city"
    t.string   "state"
    t.text     "bio"
    t.text     "education"
    t.boolean  "networking"
    t.boolean  "mentoring"
    t.boolean  "menteeing"
    t.string   "zip"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.text     "career"
    t.float    "lat"
    t.float    "lng"
    t.boolean  "admin",                                   :default => false
    t.string   "gender"
    t.datetime "birthday"
    t.datetime "profile_updated_at"
    t.string   "password_reset_code",       :limit => 40
    t.string   "time_zone"
    t.text     "websites"
    t.string   "country"
    t.string   "pronoun_type",                            :default => "they"
    t.integer  "activity_level",                          :default => 0
  end

end
