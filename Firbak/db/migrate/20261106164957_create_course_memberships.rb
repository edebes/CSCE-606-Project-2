class CreateCourseMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :course_memberships do |t|
      t.references :course, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false

      t.timestamps
    end
    add_index :course_memberships, [ :course_id, :user_id ], unique: true
  end
end
