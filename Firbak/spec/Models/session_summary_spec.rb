require "rails_helper"

# Issue #32 - summary of answers and most-missed questions when a session ends
RSpec.describe Session, "summary", type: :model do
  let(:host) do
    User.create!(name: "Anne", email: "anne.summary@tamu.edu",
                 role: "instructor", password: "password123")
  end
  let(:alice) do
    User.create!(name: "Alice", email: "alice.summary@tamu.edu",
                 role: "student", password: "password123")
  end
  let(:bob) do
    User.create!(name: "Bob", email: "bob.summary@tamu.edu",
                 role: "student", password: "password123")
  end
  let(:question_set) { QuestionSet.create!(title: "Summary Set", owner_id: host.id) }
  let(:q1) { Question.create!(number: 1, body: "What is 3 * 2?", question_set_id: question_set.id) }
  let(:q2) { Question.create!(number: 2, body: "What is 4 * 4?", question_set_id: question_set.id) }
  let!(:q1_wrong) { Choice.create!(body: "5", correct: false, question: q1) }
  let!(:q1_right) { Choice.create!(body: "6", correct: true, question: q1) }
  let!(:q2_wrong) { Choice.create!(body: "8", correct: false, question: q2) }
  let!(:q2_right) { Choice.create!(body: "16", correct: true, question: q2) }
  let(:live_session) do
    Session.create!(host: host, question_set: question_set, code: "8101", status: "active")
  end

  def answer(student, question, choice)
    Response.create!(session: live_session, user: student, question: question, choice: choice)
  end

  def summary_for(body)
    live_session.session_summary["questions"].find { |question| question["body"] == body }
  end

  it "counts only each student's first attempt at a question" do
    answer(alice, q1, q1_wrong)
    answer(alice, q1, q1_right)
    live_session.end

    expect(summary_for("What is 3 * 2?")).to include("answered" => 1, "correct" => 0, "missed" => 1)
  end

  it "counts how many students chose each choice" do
    answer(alice, q1, q1_wrong)
    answer(bob, q1, q1_right)
    live_session.end

    counts = summary_for("What is 3 * 2?")["choices"].to_h { |choice| [ choice["body"], choice["count"] ] }
    expect(counts).to eq("5" => 1, "6" => 1)
  end

  it "lists the most missed questions first" do
    answer(alice, q1, q1_right)
    answer(bob, q1, q1_right)
    answer(alice, q2, q2_wrong)
    answer(bob, q2, q2_wrong)
    live_session.end

    order = live_session.session_summary["most_missed"].map { |question| question["body"] }
    expect(order).to eq([ "What is 4 * 4?", "What is 3 * 2?" ])
  end

  it "reports no answers when nobody answered" do
    live_session.end
    expect(live_session.session_summary["answered"]).to eq(0)
  end
end