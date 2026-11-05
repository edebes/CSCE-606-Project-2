class AddQuestionRefToChoice < ActiveRecord::Migration[8.1]
  def change
    add_reference :choices, :question, null: false, foreign_key: true
  end
end
