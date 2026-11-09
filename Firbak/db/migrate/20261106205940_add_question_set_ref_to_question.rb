class AddQuestionSetRefToQuestion < ActiveRecord::Migration[8.1]
  def change
    add_reference :questions, :question_set, null: false, foreign_key: true
  end
end
