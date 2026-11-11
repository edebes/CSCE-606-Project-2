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
end
