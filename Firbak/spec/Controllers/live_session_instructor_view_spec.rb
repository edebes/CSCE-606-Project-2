require "rails_helper"

RSpec.describe SessionsController, type: :controller do
  let(:instructor) { create_user(role: "instructor", name: "Anne") }
  let(:student) { create_user(role: "student", name: "John") }
  let(:question_set) { QuestionSet.create!(title: "Math", owner: instructor) }
  let(:question) do
    Question.create!(number: 1, body: "What is 2 + 2?", question_set: question_set)
  end
  let(:correct_choice) { Choice.create!(body: "4", correct: true, question: question) }
  let(:incorrect_choice) { Choice.create!(body: "5", correct: false, question: question) }
  let(:live_session) do
    Session.create!(
      question_set: question_set,
      host: instructor,
      code: Session.generate_unique_code,
      status: "active"
    )
  end

  before do
    live_session.participants << student
    session[:user_id] = instructor.id
  end

  it "provides each student's latest response grouped by question" do
    live_session.submit_response(student, question, incorrect_choice)
    latest_response = live_session.submit_response(student, question, correct_choice)

    get :show, params: { id: live_session.id }

    expect(assigns(:latest_response_by_user).dig(student.id)).to eq(latest_response)
  end

  private

  def create_user(role:, name:)
    user_id = User.maximum(:user_id).to_i + 1
    User.create!(
      user_id: user_id,
      name: name,
      email: "live-session-#{user_id}@example.com",
      role: role
    )
  end
end
