class AddConstraintsToResponses < ActiveRecord::Migration[8.1]
  def change
    change_column_null :responses, :session_id, false
    change_column_null :responses, :user_id, false
    change_column_null :responses, :question_id, false
    change_column_null :responses, :choice_id, false

    add_index :responses, [:session_id, :user_id]
  end
end
