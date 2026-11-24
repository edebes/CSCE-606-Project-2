require "rails_helper"

RSpec.describe ResponsesController, type: :controller do
  def create_user!(attrs)
    password = "password123"
    User.create!(
      attrs.merge(
        password: password,
        password_confirmation: password
      )
    )
  end

  def log_in(user)
    session[:user_id] = user.id
  end

  def submit(choice)
    post :create, params: { session_id: live_session.id, choice_id: choice&.id }
  end

  let!(:host) do
     User.find_by(email: "anne.response@tamu.edu") ||
       create_user!(name: "Anne Host", email: "anne.response@tamu.edu", role: "instructor")
  end

  let!(:other_instructor) do 
    User.find_by(email: "ian.response@tamu.edu") ||
      create_user!(name: "Ian Other", email: "ian.response@tamu.edu", role: "instructor")
  end

  let!(:ta) do
    User.find_by(email: "theo.response@tamu.edu") ||
      create_user!(name: "Theo TA", email: "theo.response@tamu.edu", role: "ta")
  end

  let!(:student) do
    User.find_by(email: "alice.response@tamu.edu") ||
      create_user!(name: "Alice Student", email: "alice.response@tamu.edu", role: "student")
  end

  let!(:outsider) do
    User.find_by(email: "bob.response@tamu.edu") ||
      create_user!(name: "Bob Outsider", email: "bob.response@tamu.edu", role: "student")
  end

  let!(:question_set) do
    QuestionSet.find_by(title: "Week 5") ||
      QuestionSet.create!(title: "Week 5", owner: host)
  end

  let!(:question1) do
    Question.find_by(question_set: question_set, number: 1) ||
      Question.create!(question_set: question_set, number: 1, body: "What is 3 * 2?")
  end

  let!(:question2) do
    Question.find_by(question_set: question_set, number: 2) ||
      Question.create!(question_set: question_set, number: 2, body: "What is 4 * 4?")
  end

  let!(:wrong1) do
    Choice.find_by(question: question1, body: "5") ||
      Choice.create!(question: question1, body: "5", correct: false)
  end

  let!(:right1) do
    Choice.find_by(question: question1, body: "6") ||
      Choice.create!(question: question1, body: "6", correct: true)
  end

  let!(:wrong2) do
    Choice.find_by(question: question2, body: "8") ||
      Choice.create!(question: question2, body: "8", correct: false)
  end

  let!(:right2) do
    Choice.find_by(question: question2, body: "16") ||
      Choice.create!(question: question2, body: "16", correct: true)
  end

  let!(:live_session) do
    Session.find_by(question_set: question_set, host: host) ||
      Session.create!(question_set: question_set, host: host, code: "8101", status: "active", summary: {})
  end

  describe "authentication" do
    it "redirects a logged-out user to the login page" do
      expect { submit(right1) }.not_to change(Response, :count)
      expect(response).to redirect_to(login_path)
    end
  end

  describe "POST #create" do
    context "as a student who has joined" do
      before do
        live_session.join(student, "8101")
        log_in(student)
      end

      it "records a correct answer and returns to the session" do
        expect { submit(right1) }.to change(Response, :count).by(1)

        saved = Response.last
        expect(saved.user).to eq(student)
        expect(saved.question).to eq(question1)
        expect(saved.correct).to be(true)
        expect(response).to redirect_to(session_path(live_session))
        expect(flash[:alert]).to be_nil
      end

      it "moves the student to the next question after a correct answer" do
        submit(right1)

        expect(live_session.current_question_for(student)).to eq(question2)
      end

      it "records a wrong answer and keeps the student on the same question" do
        expect { submit(wrong1) }.to change(Response, :count).by(1)

        expect(Response.last.correct).to be(false)
        expect(live_session.current_question_for(student)).to eq(question1)
      end

      it "rejects a choice that belongs to a different question" do
        expect { submit(right2) }.not_to change(Response, :count)

        expect(response).to redirect_to(session_path(live_session))
        expect(flash[:alert]).to eq("Invalid question or choice.")
      end

      it "rejects a missing choice" do
        expect { submit(nil) }.not_to change(Response, :count)

        expect(response).to redirect_to(session_path(live_session))
        expect(flash[:alert]).to eq("Invalid question or choice.")
      end

      it "tells the student when every question is done" do
        submit(right1)
        submit(right2)

        expect { submit(right2) }.not_to change(Response, :count)
        expect(response).to redirect_to(session_path(live_session))
        expect(flash[:notice]).to eq("You have completed all questions in this session.")
      end

      it "rejects an answer once the session has ended" do
        live_session.end

        expect { submit(right1) }.not_to change(Response, :count)
        expect(response).to redirect_to(session_path(live_session))
        expect(flash[:alert]).to eq("Session has ended.")
      end
    end

    context "as a TA who has joined" do
      before do
        live_session.join(ta, "8101")
        log_in(ta)
      end

      it "does not record the answer" do
        expect { submit(right1) }.not_to change(Response, :count)

        expect(response).to redirect_to(session_path(live_session))
        expect(flash[:alert]).to eq("Only students can submit answers.")
      end
    end

    context "as a non-host instructor who has joined" do
      before do
        live_session.join(other_instructor, "8101")
        log_in(other_instructor)
      end

      it "does not record the answer" do
        expect { submit(right1) }.not_to change(Response, :count)

        expect(response).to redirect_to(session_path(live_session))
        expect(flash[:alert]).to eq("Only students can submit answers.")
      end
    end

    context "as the host" do
      before { log_in(host) }

      it "does not record the answer" do
        expect { submit(right1) }.not_to change(Response, :count)

        expect(response).to redirect_to(session_path(live_session))
        expect(flash[:alert]).to eq("You are not a participant in this session.")
      end
    end

    context "as a student who has not joined" do
      before { log_in(outsider) }

      it "does not record the answer" do
        expect { submit(right1) }.not_to change(Response, :count)

        expect(response).to redirect_to(session_path(live_session))
        expect(flash[:alert]).to eq("You are not a participant in this session.")
      end
    end

    context "as a TA who has not joined" do
      before { log_in(ta) }

      it "does not record the answer" do
        expect { submit(right1) }.not_to change(Response, :count)

        expect(flash[:alert]).to eq("You are not a participant in this session.")
      end
    end

    context "as a non-host instructor who has not joined" do
      before { log_in(other_instructor) }

      it "does not record the answer" do
        expect { submit(right1) }.not_to change(Response, :count)

        expect(flash[:alert]).to eq("You are not a participant in this session.")
      end
    end
  end
end