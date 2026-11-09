class CreateQuestionSets < ActiveRecord::Migration[8.1]
  def change
    create_table :question_sets do |t|
      t.string :title
      t.integer :owner_id, null: false

      t.timestamps
    end
  end
end
