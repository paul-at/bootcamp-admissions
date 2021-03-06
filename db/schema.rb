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

ActiveRecord::Schema.define(version: 20161231151829) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admission_committee_members", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "klass_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["klass_id"], name: "index_admission_committee_members_on_klass_id", using: :btree
    t.index ["user_id"], name: "index_admission_committee_members_on_user_id", using: :btree
  end

  create_table "answers", force: :cascade do |t|
    t.integer  "app_form_id"
    t.string   "question"
    t.text     "answer"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["app_form_id", "question"], name: "index_answers_on_app_form_id_and_question", using: :btree
    t.index ["app_form_id"], name: "index_answers_on_app_form_id", using: :btree
  end

  create_table "app_forms", force: :cascade do |t|
    t.string   "aasm_state"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "country",         limit: 2
    t.string   "residence"
    t.string   "gender",          limit: 1
    t.date     "dob"
    t.string   "referral"
    t.decimal  "paid",                      precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.integer  "klass_id"
    t.integer  "payment_tier_id"
    t.string   "city"
    t.integer  "interviewer_id"
    t.string   "residence_city"
    t.string   "phone"
    t.boolean  "deleted",                                            default: false, null: false
    t.index ["aasm_state"], name: "index_app_forms_on_aasm_state", using: :btree
    t.index ["country"], name: "index_app_forms_on_country", using: :btree
    t.index ["email"], name: "index_app_forms_on_email", using: :btree
    t.index ["firstname"], name: "index_app_forms_on_firstname", using: :btree
    t.index ["interviewer_id"], name: "index_app_forms_on_interviewer_id", using: :btree
    t.index ["klass_id"], name: "index_app_forms_on_klass_id", using: :btree
    t.index ["lastname"], name: "index_app_forms_on_lastname", using: :btree
    t.index ["payment_tier_id"], name: "index_app_forms_on_payment_tier_id", using: :btree
    t.index ["residence"], name: "index_app_forms_on_residence", using: :btree
    t.index ["updated_at"], name: "index_app_forms_on_updated_at", using: :btree
  end

  create_table "attachments", force: :cascade do |t|
    t.integer  "app_form_id"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.string   "field"
    t.string   "original_file_name"
    t.integer  "user_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.index ["app_form_id"], name: "index_attachments_on_app_form_id", using: :btree
    t.index ["user_id"], name: "index_attachments_on_user_id", using: :btree
  end

  create_table "email_rules", force: :cascade do |t|
    t.integer  "klass_id",                          null: false
    t.string   "state",                             null: false
    t.integer  "email_template_id",                 null: false
    t.boolean  "copy_team",         default: false, null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.index ["email_template_id"], name: "index_email_rules_on_email_template_id", using: :btree
    t.index ["klass_id", "state"], name: "index_email_rules_on_klass_id_and_state", using: :btree
    t.index ["klass_id"], name: "index_email_rules_on_klass_id", using: :btree
  end

  create_table "email_templates", force: :cascade do |t|
    t.string   "title"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emails", force: :cascade do |t|
    t.string   "subject"
    t.text     "body"
    t.integer  "app_form_id",                 null: false
    t.boolean  "sent",        default: false, null: false
    t.string   "sent_to"
    t.integer  "user_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "cc"
    t.string   "bcc"
    t.index ["app_form_id"], name: "index_emails_on_app_form_id", using: :btree
    t.index ["user_id"], name: "index_emails_on_user_id", using: :btree
  end

  create_table "histories", force: :cascade do |t|
    t.integer  "app_form_id"
    t.text     "text"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "from"
    t.string   "to"
    t.index ["app_form_id"], name: "index_histories_on_app_form_id", using: :btree
    t.index ["user_id"], name: "index_histories_on_user_id", using: :btree
  end

  create_table "interview_notes", force: :cascade do |t|
    t.integer  "app_form_id"
    t.integer  "user_id"
    t.text     "text"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["app_form_id"], name: "index_interview_notes_on_app_form_id", using: :btree
    t.index ["user_id"], name: "index_interview_notes_on_user_id", using: :btree
  end

  create_table "klasses", force: :cascade do |t|
    t.integer  "subject_id"
    t.string   "title"
    t.boolean  "archived",              default: false, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "payment_tier_id"
    t.text     "scoring_criteria"
    t.integer  "admission_threshold"
    t.integer  "scholarship_threshold"
    t.index ["payment_tier_id"], name: "index_klasses_on_payment_tier_id", using: :btree
    t.index ["subject_id"], name: "index_klasses_on_subject_id", using: :btree
  end

  create_table "payment_tiers", force: :cascade do |t|
    t.string   "title"
    t.decimal  "deposit",    precision: 10, scale: 2
    t.decimal  "tuition",    precision: 10, scale: 2
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "scores", force: :cascade do |t|
    t.integer  "app_form_id"
    t.integer  "user_id"
    t.string   "criterion"
    t.integer  "score"
    t.string   "reason"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["app_form_id"], name: "index_scores_on_app_form_id", using: :btree
    t.index ["criterion"], name: "index_scores_on_criterion", using: :btree
    t.index ["user_id"], name: "index_scores_on_user_id", using: :btree
  end

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree
  end

  create_table "subjects", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "klass_id",   null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["klass_id"], name: "index_subscriptions_on_klass_id", using: :btree
    t.index ["user_id"], name: "index_subscriptions_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false, null: false
    t.boolean  "staff",                  default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "app_form_id"
    t.integer  "user_id"
    t.boolean  "vote"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["app_form_id"], name: "index_votes_on_app_form_id", using: :btree
    t.index ["user_id"], name: "index_votes_on_user_id", using: :btree
  end

  add_foreign_key "admission_committee_members", "klasses"
  add_foreign_key "admission_committee_members", "users"
  add_foreign_key "answers", "app_forms"
  add_foreign_key "app_forms", "klasses"
  add_foreign_key "app_forms", "payment_tiers"
  add_foreign_key "app_forms", "users", column: "interviewer_id"
  add_foreign_key "attachments", "app_forms"
  add_foreign_key "attachments", "users"
  add_foreign_key "email_rules", "email_templates"
  add_foreign_key "email_rules", "klasses"
  add_foreign_key "emails", "app_forms"
  add_foreign_key "emails", "users"
  add_foreign_key "histories", "app_forms"
  add_foreign_key "histories", "users"
  add_foreign_key "interview_notes", "app_forms"
  add_foreign_key "interview_notes", "users"
  add_foreign_key "klasses", "payment_tiers"
  add_foreign_key "klasses", "subjects"
  add_foreign_key "scores", "app_forms"
  add_foreign_key "scores", "users"
  add_foreign_key "subscriptions", "klasses"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "votes", "app_forms"
  add_foreign_key "votes", "users"
end
