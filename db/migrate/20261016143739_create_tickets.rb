class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :customer_name, null: false
      t.string :customer_email, null: false
      t.integer :priority, default: 1, null: false
      t.integer :status, default: 0, null: false
      t.string :assigned_agent
      t.integer :sla_hours, default: 8, null: false
      t.datetime :sla_due_at
      t.boolean :sla_breached, default: false, null: false
      t.datetime :first_responded_at
      t.datetime :resolved_at
      t.integer :gratitude_count, default: 0, null: false

      t.timestamps
    end

    add_index :tickets, :status
    add_index :tickets, :priority
    add_index :tickets, :sla_due_at
    add_index :tickets, :sla_breached
  end
end
