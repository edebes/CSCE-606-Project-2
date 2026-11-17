class CreateQuestionSets < ActiveRecord::Migration[8.1]
  def change
    create_table :question_sets do |t|
      t.string :title
      t.references :owner, foreign_key: {to_table: :users}, null: false

      t.timestamps
    end
  end
end
