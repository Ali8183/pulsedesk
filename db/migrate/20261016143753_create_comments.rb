class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :ticket, null: false, foreign_key: true
      t.string :author_name, null: false
      t.string :author_role, default: "customer", null: false
      t.text :body, null: false
      t.boolean :is_gratitude, default: false, null: false

      t.timestamps
    end

    add_index :comments, :is_gratitude
  end
end
