# Issue #67 - make the database enforce the relationships the models already assume.
class CleanUpReferences < ActiveRecord::Migration[8.1]
  def up
    # users.user_id duplicated the id column Rails already gives every row.
    remove_column :users, :user_id

    # Emails are now compared case-insensitively, so store them lowercased.
    execute "UPDATE users SET email = LOWER(TRIM(email)) WHERE email IS NOT NULL"
    change_column_null :users, :name, false
    change_column_null :users, :email, false
    change_column_null :users, :role, false
    add_index :users, :email, unique: true

    # Remove rows that point at records which no longer exist,
    # otherwise the foreign keys below can't be added.
    execute <<~SQL
      DELETE FROM responses
      WHERE session_id NOT IN (SELECT id FROM sessions)
         OR user_id NOT IN (SELECT id FROM users)
         OR question_id NOT IN (SELECT id FROM questions)
         OR choice_id NOT IN (SELECT id FROM choices)
    SQL
    execute <<~SQL
      DELETE FROM session_participants
      WHERE session_id NOT IN (SELECT id FROM sessions)
         OR user_id NOT IN (SELECT id FROM users)
    SQL
    execute <<~SQL
      DELETE FROM courses_question_sets
      WHERE course_id NOT IN (SELECT id FROM courses)
         OR question_set_id NOT IN (SELECT id FROM question_sets)
    SQL

    add_foreign_key :responses, :sessions
    add_foreign_key :responses, :users
    add_foreign_key :responses, :questions
    add_foreign_key :responses, :choices
    add_index :responses, :question_id
    add_index :responses, :choice_id

    add_foreign_key :sessions, :question_sets
    add_foreign_key :sessions, :users, column: :host_id

    add_foreign_key :session_participants, :sessions
    add_foreign_key :session_participants, :users

    # A question set can only be attached to a course once.
    remove_index :courses_question_sets, [ :course_id, :question_set_id ]
    add_index :courses_question_sets, [ :course_id, :question_set_id ], unique: true
    add_foreign_key :courses_question_sets, :courses
    add_foreign_key :courses_question_sets, :question_sets
  end

  def down
    remove_foreign_key :courses_question_sets, :question_sets
    remove_foreign_key :courses_question_sets, :courses
    remove_index :courses_question_sets, [ :course_id, :question_set_id ]
    add_index :courses_question_sets, [ :course_id, :question_set_id ]

    remove_foreign_key :session_participants, :users
    remove_foreign_key :session_participants, :sessions

    remove_foreign_key :sessions, column: :host_id
    remove_foreign_key :sessions, :question_sets

    remove_index :responses, :choice_id
    remove_index :responses, :question_id
    remove_foreign_key :responses, :choices
    remove_foreign_key :responses, :questions
    remove_foreign_key :responses, :users
    remove_foreign_key :responses, :sessions

    remove_index :users, :email
    change_column_null :users, :role, true
    change_column_null :users, :email, true
    change_column_null :users, :name, true
    add_column :users, :user_id, :integer
  end
end