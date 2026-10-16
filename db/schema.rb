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

ActiveRecord::Schema[8.1].define(version: 2026_10_16_143753) do
  create_table "comments", force: :cascade do |t|
    t.integer "ticket_id", null: false
    t.string "author_name", null: false
    t.string "author_role", default: "customer", null: false
    t.text "body", null: false
    t.boolean "is_gratitude", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_gratitude"], name: "index_comments_on_is_gratitude"
    t.index ["ticket_id"], name: "index_comments_on_ticket_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.string "customer_name", null: false
    t.string "customer_email", null: false
    t.integer "priority", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.string "assigned_agent"
    t.integer "sla_hours", default: 8, null: false
    t.datetime "sla_due_at"
    t.boolean "sla_breached", default: false, null: false
    t.datetime "first_responded_at"
    t.datetime "resolved_at"
    t.integer "gratitude_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority"], name: "index_tickets_on_priority"
    t.index ["sla_breached"], name: "index_tickets_on_sla_breached"
    t.index ["sla_due_at"], name: "index_tickets_on_sla_due_at"
    t.index ["status"], name: "index_tickets_on_status"
  end

  add_foreign_key "comments", "tickets"
end
