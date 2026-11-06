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
  { user_id: 12345, name: 'John Doe',
    email: 'john.doe@tamu.edu', role: 'student' },
  { user_id: 24680, name: 'Anne Smith',
    email: 'anne.smith@tamu.edu', role: 'instructor' },
  { user_id: 13579, name: 'Alfonzo Rebeiro',
    email: 'alfonzo.rebeiro@tamu.edu', role: 'ta' }
]

more_users.each do |user|
  User.create!(user)
end

question_seeds = [
  { body: "2 x 3 = ?", number: 1 },
  { body: "2 + 3 = ?", number: 2 },
  { body: "6 / 2 = ?", number: 3 }
]

question_seeds.each do |question|
  Question.create!(question)
end

question_1_choices = [
  { body: "6", correct: true },
  { body: "5", correct: false },
  { body: "1", correct: false },
  { body: "1.5", correct: false }
]

question_2_choices = [
  { body: "6", correct: false },
  { body: "5", correct: true },
  { body: "1", correct: false },
  { body: "1.5", correct: false }
]

question_3_choices = [
  { body: "6", correct: false },
  { body: "5", correct: false },
  { body: "12", correct: false },
  { body: "3", correct: true }
]

question_1_choices.each do |choice|
  question = Question.find_by(body: "2 x 3 = ?")
  question.choices.create!(choice)
end

question_2_choices.each do |choice|
  question = Question.find_by(body: "2 + 3 = ?")
  question.choices.create!(choice)
end

question_3_choices.each do |choice|
  question = Question.find_by(body: "6 / 2 = ?")
  question.choices.create!(choice)
end
