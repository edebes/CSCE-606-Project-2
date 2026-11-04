class CreateChoices < ActiveRecord::Migration[8.1]
  def change
    create_table :choices do |t|
      t.text :body
      t.boolean :correct
      t.text :feedback

      t.timestamps
    end
  end
end
