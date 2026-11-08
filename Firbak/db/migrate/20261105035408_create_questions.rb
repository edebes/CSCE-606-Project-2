class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions do |t|
      t.integer :number
      t.text :body

      t.timestamps
    end
  end
end
