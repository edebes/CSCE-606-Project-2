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

more_users.each do |user|
  User.find_or_create_by!(email: user[:email]) do |record|
    record.user_id = user[:user_id]
    record.name = user[:name]
    record.role = user[:role]
  end
end

instructor = User.find_by!(email: "anne.smith@tamu.edu")
student = User.find_by!(email: "john.doe@tamu.edu")

demo_session = Session.find_or_create_by!(code: "1234") do |session|
  session.question_set_id = 1
  session.host = instructor
  session.status = "active"
  session.summary = {}
end

demo_session.participants << student unless demo_session.participants.include?(student)