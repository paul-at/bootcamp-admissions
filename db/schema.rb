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

ActiveRecord::Schema.define(version: 20160905233457) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.integer  "app_form_id"
    t.string   "question"
    t.text     "answer"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["app_form_id"], name: "index_answers_on_app_form_id", using: :btree
  end

  create_table "app_forms", force: :cascade do |t|
    t.string   "aasm_state"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "country",    limit: 2
    t.string   "residence"
    t.string   "gender",     limit: 1
    t.date     "dob"
    t.string   "referral"
    t.decimal  "paid",                 precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.integer  "klass_id"
    t.index ["aasm_state"], name: "index_app_forms_on_aasm_state", using: :btree
    t.index ["country"], name: "index_app_forms_on_country", using: :btree
    t.index ["email"], name: "index_app_forms_on_email", using: :btree
    t.index ["firstname"], name: "index_app_forms_on_firstname", using: :btree
    t.index ["klass_id"], name: "index_app_forms_on_klass_id", using: :btree
    t.index ["lastname"], name: "index_app_forms_on_lastname", using: :btree
    t.index ["residence"], name: "index_app_forms_on_residence", using: :btree
    t.index ["updated_at"], name: "index_app_forms_on_updated_at", using: :btree
  end

  create_table "klasses", force: :cascade do |t|
    t.integer  "subject_id"
    t.string   "title"
    t.boolean  "archived",                            default: false, null: false
    t.decimal  "deposit",    precision: 10, scale: 2
    t.decimal  "tuition",    precision: 10, scale: 2
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.index ["subject_id"], name: "index_klasses_on_subject_id", using: :btree
  end

  create_table "subjects", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "answers", "app_forms"
  add_foreign_key "app_forms", "klasses"
  add_foreign_key "klasses", "subjects"
end
