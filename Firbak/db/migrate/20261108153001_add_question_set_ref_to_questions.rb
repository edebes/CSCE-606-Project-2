class AddQuestionSetRefToQuestions < ActiveRecord::Migration[8.1]
  def change
    add_reference :questions, :question_set, foreign_key: true
  end
end
