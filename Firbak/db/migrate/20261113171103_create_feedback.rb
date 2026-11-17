class CreateFeedback < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.text :content
      t.references :to_user, foreign_key: { to_table: :users }
      t.references :from_user, foreign_key: { to_table: :users }
      t.references :question, foreign_key: true
      t.references :session, foreign_key: true
      t.timestamp :delivered

      t.timestamps
    end
  end
end
