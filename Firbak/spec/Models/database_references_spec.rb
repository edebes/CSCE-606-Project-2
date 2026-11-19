require "rails_helper"

# Issue #67 - database and model references
RSpec.describe "Database references", type: :model do
  let(:instructor) do
    User.create!(name: "Anne", email: "anne.refs@tamu.edu", role: "instructor", password: "password123")
  end
  let(:student) do
    User.create!(name: "John", email: "john.refs@tamu.edu", role: "student", password: "password123")
  end
  let(:question_set) { QuestionSet.create!(title: "References Set", owner: instructor) }
  let(:question) { Question.create!(number: 1, body: "What is 3 * 2?", question_set: question_set) }
  let(:choice) { Choice.create!(body: "6", correct: true, question: question) }
  let(:live_session) do
    Session.create!(host: instructor, question_set: question_set, code: "6701", status: "active")
  end

  def answer!
    Response.create!(session: live_session, user: student, question: question, choice: choice)
  end

  describe "users" do
    it "lists the question sets a user owns" do
      expect(instructor.question_sets).to contain_exactly(question_set)
    end

    it "stores emails lowercased and without spaces" do
      user = User.create!(name: "Kim", email: "  Kim.Lee@TAMU.edu ", role: "student")
      expect(user.email).to eq("kim.lee@tamu.edu")
    end

    it "treats emails that differ only by case as the same account" do
      User.create!(name: "Kim", email: "kim.lee@tamu.edu", role: "student")
      duplicate = User.new(name: "Kim Again", email: "KIM.LEE@tamu.edu", role: "student")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to be_present
    end

    it "finds a user by email regardless of case" do
      student
      expect(User.find_by(email: "JOHN.REFS@tamu.edu")).to eq(student)
    end

    it "rejects an email that isn't an email address" do
      user = User.new(name: "Kim", email: "not-an-email", role: "student")
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end
  end

  describe "deleting records" do
    it "deletes a question set along with its questions, choices, sessions and answers" do
      answer!
      expect { question_set.destroy! }.not_to raise_error
      expect(Question.where(id: question.id)).to be_empty
      expect(Choice.where(id: choice.id)).to be_empty
      expect(Session.where(id: live_session.id)).to be_empty
      expect(Response.count).to eq(0)
    end

    it "deletes a student along with their answers and session memberships" do
      live_session.join(student, live_session.code)
      answer!
      expect { student.destroy! }.not_to raise_error
      expect(Response.count).to eq(0)
      expect(live_session.reload.participants).to be_empty
    end

    it "deletes an instructor along with the sessions they hosted and the sets they own" do
      answer!
      expect { instructor.destroy! }.not_to raise_error
      expect(Session.where(id: live_session.id)).to be_empty
      expect(QuestionSet.where(id: question_set.id)).to be_empty
    end
  end

  describe "foreign keys" do
    it "won't save an answer that points at a session that doesn't exist" do
      bad = Response.new(session_id: 999_999, user: student, question: question, choice: choice)
      expect { bad.save!(validate: false) }.to raise_error(ActiveRecord::InvalidForeignKey)
    end

    it "won't save a session whose host doesn't exist" do
      bad = Session.new(host_id: 999_999, question_set: question_set, code: "6702", status: "active")
      expect { bad.save!(validate: false) }.to raise_error(ActiveRecord::InvalidForeignKey)
    end
  end
end