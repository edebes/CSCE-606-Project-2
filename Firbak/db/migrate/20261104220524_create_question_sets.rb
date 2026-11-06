class CreateQuestionSets < ActiveRecord::Migration[8.1]
  def change
    create_table :question_sets do |t|
      t.string :title
      t.integer :owner
      t.json :questions, default: []

      t.timestamps
    end
  end
end
