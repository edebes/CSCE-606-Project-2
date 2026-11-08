class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.integer :question_set_id, null: false
      t.integer :host_id, null: false
      t.string :code, null: false
      t.string :status, null: false, default: "active"
      t.json :summary, default: {}

      t.timestamps
    end

    add_index :sessions, :code, unique: true
    add_index :sessions, :question_set_id
    add_index :sessions, :host_id
    add_index :sessions, :status
  end
end
