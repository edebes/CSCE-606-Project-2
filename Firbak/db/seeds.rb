# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
more_users = [
  {:user_id => 12345, :name => 'John Doe',
    :email => 'john.doe@tamu.edu', :role => 'student'},
  {:user_id => 24680, :name => 'Anne Smith',
    :email => 'anne.smith@tamu.edu', :role => 'instructor'},
  {:user_id => 13579, :name => 'Alfonzo Rebeiro',
    :email => 'alfonzo.rebeiro@tamu.edu', :role => 'ta'},
]
# t.string :title
# t.integer :owner
# t.integer :questions, array: true, default: []
question_sets = [
  {:title => "Basic Math", :owner => 24680,
    :question => [1, 2, 3, 4, 5]},
  {:title => "Python Review", :owner => 13579,
    :question => [6, 7, 8]},
  {:title => "Algebra", :owner => 24680,
    :question => [9, 10]},
]

more_users.each do |user|
  User.create!(user)
end

question_sets.each do |question_set|
  QuestionSet.create!(question_set)
end