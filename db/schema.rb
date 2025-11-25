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

ActiveRecord::Schema[8.0].define(version: 2025_11_25_113012) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "consent_records", force: :cascade do |t|
    t.uuid "user_id"
    t.string "data_subject_identifier", null: false
    t.string "purpose", null: false
    t.boolean "granted", default: true, null: false
    t.datetime "granted_at"
    t.datetime "revoked_at"
    t.string "source"
    t.string "jurisdiction", default: "US"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_subject_identifier", "purpose"], name: "index_consent_records_on_subject_and_purpose", unique: true
    t.index ["user_id"], name: "index_consent_records_on_user_id"
  end

  create_table "data_subject_requests", force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "data_subject_identifier", null: false
    t.string "request_type", null: false
    t.string "status", default: "queued", null: false
    t.datetime "due_at"
    t.datetime "completed_at"
    t.jsonb "metadata", default: {}
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_subject_identifier", "request_type"], name: "index_dsr_on_identifier_and_type"
    t.index ["request_type"], name: "index_data_subject_requests_on_request_type"
    t.index ["status"], name: "index_data_subject_requests_on_status"
    t.index ["user_id"], name: "index_data_subject_requests_on_user_id"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.uuid "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "otp_secret"
    t.boolean "otp_required_for_login", default: false
    t.text "otp_backup_codes", default: [], array: true
    t.text "first_name_ciphertext"
    t.text "last_name_ciphertext"
    t.text "phone_number_ciphertext"
    t.text "date_of_birth_ciphertext"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "email_ciphertext"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.uuid "user_id"
    t.uuid "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.uuid "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.text "object_changes"
    t.datetime "created_at"
    t.index ["created_at"], name: "index_versions_on_created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["whodunnit"], name: "index_versions_on_whodunnit"
  end

  add_foreign_key "consent_records", "users"
  add_foreign_key "data_subject_requests", "users"
end
