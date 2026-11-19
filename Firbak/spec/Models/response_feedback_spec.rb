require "rails_helper"

# Issue #28 - pre-programmed feedback on wrong answers
RSpec.describe Response, "#feedback", type: :model do
  let(:host) do
    User.create!(name: "Anne", email: "anne.feedback@tamu.edu",
                 role: "instructor", password: "password123")
  end
  let(:student) do
    User.create!(name: "John", email: "john.feedback@tamu.edu",
                 role: "student", password: "password123")
  end
  let(:question_set) { QuestionSet.create!(title: "Feedback Set", owner_id: host.id) }
  let(:question) { Question.create!(number: 1, body: "What is 3 * 2?", question_set_id: question_set.id) }
  let(:live_session) do
    Session.create!(host: host, question_set: question_set, code: "7101", status: "active")
  end

  def respond_with(choice)
    Response.create!(session: live_session, user: student, question: question, choice: choice)
  end

  it "returns the pre-programmed feedback for a wrong choice" do
    wrong = Choice.create!(body: "5", correct: false, feedback: "That is 3 + 2", question: question)
    expect(respond_with(wrong).feedback).to eq("That is 3 + 2")
  end

  it "returns nothing for the correct choice" do
    right = Choice.create!(body: "6", correct: true, feedback: "Nice", question: question)
    expect(respond_with(right).feedback).to be_nil
  end

  it "returns nothing for a wrong choice with no feedback written" do
    blank = Choice.create!(body: "8", correct: false, feedback: "", question: question)
    expect(respond_with(blank).feedback).to be_nil
  end
end