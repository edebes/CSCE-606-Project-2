class CreateQuestionSets < ActiveRecord::Migration[8.1]
  def change
    create_table :question_sets do |t|
      t.string :title, null: false
      t.integer :owner_id, null: false
      t.timestamps
    end

    add_index :question_sets, :owner_id
  end
end
