class CreateSessionParticipants < ActiveRecord::Migration[8.1]
  def change
    # HABTM join table: no primary key / timestamps
    create_table :session_participants, id: false do |t|
      t.integer :session_id, null: false
      t.integer :user_id, null: false
    end

    add_index :session_participants, [:session_id, :user_id], unique: true
    add_index :session_participants, :user_id
  end
end
