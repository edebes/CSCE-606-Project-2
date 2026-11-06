class AddQuestionSetRefToQuestion < ActiveRecord::Migration[8.1]
  def change
    add_reference :question, :question_sets, null: false, foreign_key: true
  end
end
