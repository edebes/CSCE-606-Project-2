# Idempotent seeds for local demos.

more_users = [
  { user_id: 12345, name: "John Doe", email: "john.doe@tamu.edu", role: "student" },
  { user_id: 24680, name: "Anne Smith", email: "anne.smith@tamu.edu", role: "instructor" },
  { user_id: 13579, name: "Alfonzo Rebeiro", email: "alfonzo.rebeiro@tamu.edu", role: "ta" }
]

more_users.each do |attrs|
  user = User.find_or_initialize_by(email: attrs[:email])
  user.assign_attributes(
    user_id: attrs[:user_id],
    name: attrs[:name],
    role: attrs[:role],
    password: "password123",
    password_confirmation: "password123"
  )
  user.save!
end

instructor = User.find_by!(email: "anne.smith@tamu.edu")
student = User.find_by!(email: "john.doe@tamu.edu")

week_5 = QuestionSet.find_or_create_by!(title: "Week 5", owner: instructor)

question = week_5.questions.find_or_create_by!(number: 1, body: "2 x 3 = ?")
[
  { body: "6", correct: true },
  { body: "5", correct: false, feedback: "You added instead of multiplied" },
  { body: "1", correct: false },
  { body: "1.5", correct: false }
].each do |choice_attrs|
  question.choices.find_or_create_by!(body: choice_attrs[:body]) do |choice|
    choice.correct = choice_attrs[:correct]
    choice.feedback = choice_attrs[:feedback]
  end
end

demo_session = Session.find_or_create_by!(code: "1234") do |session|
  session.question_set = week_5
  session.host = instructor
  session.status = "active"
  session.summary = {}
end

demo_session.participants << student unless demo_session.participants.include?(student)
