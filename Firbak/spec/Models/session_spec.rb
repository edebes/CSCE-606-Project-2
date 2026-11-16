# frozen_string_literal: true

require "rails_helper"

RSpec.describe Session, type: :model do
  def create_user!(attrs)
    password = "password123"
    User.create!(
      attrs.merge(
        password: password,
        password_confirmation: password
      )
    )
  end

  let!(:host) do
    User.find_by(email: "anne.session@tamu.edu") ||
      create_user!(user_id: 9001, name: "Anne Host", email: "anne.session@tamu.edu", role: "instructor")
  end

  let!(:student) do
    User.find_by(email: "alice.session@tamu.edu") ||
      create_user!(user_id: 9002, name: "Alice Student", email: "alice.session@tamu.edu", role: "student")
  end

  let!(:ta) do
    User.find_by(email: "theo.session@tamu.edu") ||
      create_user!(user_id: 9003, name: "Theo TA", email: "theo.session@tamu.edu", role: "ta")
  end

  let!(:question_set) do
    QuestionSet.find_by(title: "Session Spec Set") ||
      QuestionSet.create!(title: "Session Spec Set", owner_id: host.id)
  end

  describe "validations" do
    it "is valid with required attributes" do
      session = described_class.new(
        question_set: question_set,
        host: host,
        code: "4242",
        status: "active"
      )

      expect(session).to be_valid
    end

    it "is invalid without a question_set" do
      session = described_class.new(host: host, code: "1111", status: "active")

      expect(session).not_to be_valid
      expect(session.errors[:question_set]).to be_present
    end

    it "is invalid without a host" do
      session = described_class.new(question_set: question_set, code: "1112", status: "active")

      expect(session).not_to be_valid
      expect(session.errors[:host]).to be_present
    end

    it "is invalid without a code" do
      session = described_class.new(question_set: question_set, host: host, status: "active", code: nil)

      expect(session).not_to be_valid
      expect(session.errors[:code]).to be_present
    end

    it "requires a unique code" do
      described_class.create!(question_set: question_set, host: host, code: "5555", status: "active")
      duplicate = described_class.new(question_set: question_set, host: host, code: "5555", status: "active")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:code]).to be_present
    end

    it "only allows active or ended status" do
      session = described_class.new(
        question_set: question_set,
        host: host,
        code: "6666",
        status: "paused"
      )

      expect(session).not_to be_valid
      expect(session.errors[:status]).to be_present
    end
  end

  describe ".start" do
    it "creates an active session with a generated join code" do
      session = described_class.start(question_set_id: question_set.id, host: host)

      expect(session).to be_persisted
      expect(session.status).to eq("active")
      expect(session.host).to eq(host)
      expect(session.question_set_id).to eq(question_set.id)
      expect(session.code).to match(/\A\d{4}\z/)
    end

    it "generates different codes for successive sessions" do
      first = described_class.start(question_set_id: question_set.id, host: host)
      second = described_class.start(question_set_id: question_set.id, host: host)

      expect(first.code).not_to eq(second.code)
    end
  end

  describe "#join" do
    let!(:session) do
      described_class.create!(
        question_set: question_set,
        host: host,
        code: "1234",
        status: "active"
      )
    end

    it "lets a student join with the correct code" do
      expect(session.join(student, "1234")).to eq(:ok)
      expect(session.participants.reload).to include(student)
    end

    it "lets a TA join with the correct code" do
      expect(session.join(ta, "1234")).to eq(:ok)
      expect(session.participants.reload).to include(ta)
    end

    it "rejects a wrong code" do
      expect(session.join(student, "9999")).to eq(:invalid_code)
      expect(session.participants.reload).not_to include(student)
    end

    it "rejects a blank code" do
      expect(session.join(student, "")).to eq(:invalid_code)
      expect(session.participants.reload).not_to include(student)
    end

    it "rejects joining an ended session even with the right code" do
      session.update!(status: "ended")

      expect(session.join(student, "1234")).to eq(:ended)
      expect(session.participants.reload).not_to include(student)
    end

    it "does not duplicate a participant who joins twice" do
      session.join(student, "1234")
      session.join(student, "1234")

      expect(session.participants.reload.where(id: student.id).count).to eq(1)
    end
  end

  describe "#end" do
    let!(:session) do
      described_class.create!(
        question_set: question_set,
        host: host,
        code: "7777",
        status: "active"
      )
    end

    it "marks the session as ended and returns a summary" do
      session.join(student, "7777")
      result = session.end

      expect(session.reload.status).to eq("ended")
      expect(result["participant_count"]).to eq(1)
      expect(session.session_summary).to include("most_missed")
    end

    it "is idempotent when already ended" do
      session.end
      expect { session.end }.not_to change { session.reload.updated_at }
    end
  end

  describe "#send_live_feedback" do
    let!(:session) do
      described_class.create!(
        question_set: question_set,
        host: host,
        code: "8888",
        status: "active"
      )
    end

    before { session.join(student, "8888") }

    it "delivers feedback to a participant" do
      result = session.send_live_feedback(student, "Multiply, do not add")

      expect(result).to include(
        session_id: session.id,
        to_user_id: student.id,
        content: "Multiply, do not add",
        delivered: true
      )
    end

    it "rejects feedback to a non-participant" do
      expect(session.send_live_feedback(ta, "Nope")).to eq(:not_participant)
    end

    it "rejects feedback after the session has ended" do
      session.end

      expect(session.send_live_feedback(student, "Too late")).to eq(:ended)
    end
  end

  describe "#allow_resubmission" do
    let!(:session) do
      described_class.create!(
        question_set: question_set,
        host: host,
        code: "9991",
        status: "active"
      )
    end

    it "allows a participant to resubmit while the session is active" do
      session.join(student, "9991")

      expect(session.allow_resubmission(student, 1)).to eq(true)
    end

    it "denies resubmission after the session ends" do
      session.join(student, "9991")
      session.end

      expect(session.allow_resubmission(student, 1)).to eq(false)
    end
  end

  describe "ordered_questions" do
    let!(:session) do
      described_class.create!(
        question_set: question_set,
        host: host,
        code: "0001",
        status: "active"
      )
    end

    it "returns questions in order of their number" do
      question1 = Question.create!(body: "What is 2+2?", number: 2, question_set: question_set)
      question2 = Question.create!(body: "What is 3+3?", number: 3, question_set: question_set)

      expect(session.ordered_questions).to eq([question1, question2])
    end
  end

  describe "current_question_for" do
    let!(:session) do
      described_class.create!(
        question_set: question_set,
        host: host,
        code: "0002",
        status: "active"
      )
    end

    it "returns the first unanswered question for a participant" do
      session.join(student, "0002")
      question1 = Question.create!(body: "What is 1+1?", number: 1, question_set: question_set)
      question2 = Question.create!(body: "What is 2+2?", number: 2, question_set: question_set)
      choice1 = Choice.create!(body: "2", correct: true, question: question1)

      expect(session.current_question_for(student)).to eq(question1)

      Response.create!(session: session, user: student, question: question1, choice: choice1)

      expect(session.current_question_for(student)).to eq(question2)
    end

    it "returns nil if all questions are answered" do
      session.join(student, "0002")
      question = Question.create!(body: "What is 3+3?", number: 3, question_set: question_set)
      choice = Choice.create!(body: "6", correct: true, question: question)

      Response.create!(session: session, user: student, question: question, choice: choice)

      expect(session.current_question_for(student)).to be_nil
    end
  end

  describe "submit_response" do
    let!(:session) do
      described_class.create!(
        question_set: question_set,
        host: host,
        code: "0003",
        status: "active"
      )
    end

    it "creates a response for a valid submission" do
      session.join(student, "0003")
      question = Question.create!(body: "What is 4+4?", number: 4, question_set: question_set)
      choice = Choice.create!(body: "8", correct: true, question: question)

      result = session.submit_response(student, question, choice)

      expect(result).to be_a(Response)
      expect(result.session).to eq(session)
      expect(result.user).to eq(student)
      expect(result.question).to eq(question)
      expect(result.choice).to eq(choice)
      expect(result.correct).to be true
    end

    it "rejects submission from a non-participant" do
      question = Question.create!(body: "What is 5+5?", number: 5, question_set: question_set)
      choice = Choice.create!(body: "10", correct: true, question: question)

      expect(session.submit_response(ta, question, choice)).to eq(:not_participant)
    end

    it "rejects submission for an invalid question" do
      session.join(student, "0003")
      other_question = Question.create!(body: "What is 6+6?", number: 6, question_set: QuestionSet.create!(title: "Other Set", owner_id: host.id))
      choice = Choice.create!(body: "12", correct: true, question: other_question)

      expect(session.submit_response(student, other_question, choice)).to eq(:invalid_question)
    end

    it "rejects submission for an invalid choice" do
      session.join(student, "0003")
      question = Question.create!(body: "What is 7+7?", number: 7, question_set: question_set)
      invalid_choice = Choice.create!(body: "15", correct: false, question: Question.create!(body: "Other Question", number: 8, question_set: QuestionSet.create!(title: "Other Set", owner_id: host.id)))

      expect(session.submit_response(student, question, invalid_choice)).to eq(:invalid_choice)
    end

    it "rejects submission after the session has ended" do
      session.join(student, "0003")
      session.end
      question = Question.create!(body: "What is 8+8?", number: 8, question_set: question_set)
      choice = Choice.create!(body: "16", correct: true, question: question)

      expect(session.submit_response(student, question, choice)).to eq(:ended)
    end
  end

  describe "progress_for" do
    let!(:session) do
      described_class.create!(
        question_set: question_set,
        host: host,
        code: "0004",
        status: "active"
      )
    end

    it "returns the number of answered questions for a participant" do
      session.join(student, "0004")
      question1 = Question.create!(body: "What is 9+9?", number: 9, question_set: question_set)
      question2 = Question.create!(body: "What is 10+10?", number: 10, question_set: question_set)
      choice1 = Choice.create!(body: "18", correct: true, question: question1)
      choice2 = Choice.create!(body: "20", correct: true, question: question2)

      Response.create!(session: session, user: student, question: question1, choice: choice1)

      expect(session.progress_for(student)[:progress_percentage]).to eq(50.0)

      Response.create!(session: session, user: student, question: question2, choice: choice2)

      expect(session.progress_for(student)[:progress_percentage]).to eq(100.0)
    end

    it "returns 0 for a participant with no responses" do
      session.join(student, "0004")

      expect(session.progress_for(student)[:progress_percentage]).to eq(0)
    end
  end
end
