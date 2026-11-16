class CreateResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :responses do |t|
      t.integer :session_id
      t.integer :user_id
      t.integer :question_id
      t.integer :choice_id
      t.boolean :correct

      t.timestamps
    end
  end
end
