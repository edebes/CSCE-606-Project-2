class CreateQuestionSets < ActiveRecord::Migration[8.1]
  def change
    create_table :question_sets do |t|
      t.string :title
      t.integer :owner

      t.timestamps
    end
  end
end
