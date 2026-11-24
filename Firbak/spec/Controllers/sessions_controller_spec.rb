require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
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

  let!(:host) do
     User.find_by(email: "anne.session@tamu.edu") ||
       create_user!(name: "Anne Host", email: "anne.session@tamu.edu", role: "instructor")
  end

  let!(:other_instructor) do 
    User.find_by(email: "ian.session@tamu.edu") ||
      create_user!(name: "Ian Other", email: "ian.session@tamu.edu", role: "instructor")
  end

  let!(:ta) do
    User.find_by(email: "theo.session@tamu.edu") ||
      create_user!(name: "Theo TA", email: "theo.session@tamu.edu", role: "ta")
  end

  let!(:student) do
    User.find_by(email: "alice.session@tamu.edu") ||
      create_user!(name: "Alice Student", email: "alice.session@tamu.edu", role: "student")
  end

  let!(:outsider) do
    User.find_by(email: "bob.session@tamu.edu") ||
      create_user!(name: "Bob Outsider", email: "bob.session@tamu.edu", role: "student")
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

  let!(:live_session) do
    Session.find_by(question_set: question_set, host: host) ||
      Session.create!(question_set: question_set, host: host, code: "7876", status: "active", summary: {})
  end

  describe "authentication" do
    it "redirects a logged-out user to the login page" do
      get :show, params: { id: live_session.id }

      expect(response).to redirect_to(login_path)
      expect(flash[:alert]).to eq("You must log in first")
    end
  end

  describe "GET #show" do
    context "as the host" do
      before { log_in(host) }

      it "shows the host view" do
        get :show, params: { id: live_session.id }

        expect(response).to have_http_status(:ok)
        expect(assigns(:host_view)).to be(true)
      end
    end

    context "as a TA who has joined" do
      before do
        live_session.join(ta, "7876")
        log_in(ta)
      end

      it "shows the host view" do
        get :show, params: { id: live_session.id }

        expect(response).to have_http_status(:ok)
        expect(assigns(:host_view)).to be(true)
        expect(assigns(:current_question)).to be_nil
      end
    end

    context "as a non-host instructor who has joined" do
      before do
        live_session.join(other_instructor, "7876")
        log_in(other_instructor)
      end

      it "shows the host view" do
        get :show, params: { id: live_session.id }

        expect(response).to have_http_status(:ok)
        expect(assigns(:host_view)).to be(true)
      end
    end

    context "as a student who has joined" do
      before do
        live_session.join(student, "7876")
        log_in(student)
      end

      it "shows the student view with the first unanswered question" do
        get :show, params: { id: live_session.id }

        expect(response).to have_http_status(:ok)
        expect(assigns(:host_view)).to be_nil
        expect(assigns(:current_question)).to eq(question1)
      end

      it "moves to the next question after a correct answer" do
        Response.create!(session: live_session, user: student, question: question1, choice: right1, correct: true)

        get :show, params: { id: live_session.id }

        expect(assigns(:current_question)).to eq(question2)
        expect(assigns(:latest_response).choice).to eq(right1)
      end

      it "does not load a question once the session has ended" do
        live_session.end

        get :show, params: { id: live_session.id }

        expect(response).to have_http_status(:ok)
        expect(assigns(:current_question)).to be_nil
      end
    end

    context "as a TA who has not joined" do
      before { log_in(ta) }

      it "redirects to the join page" do
        get :show, params: { id: live_session.id }

        expect(response).to redirect_to(join_session_path)
        expect(flash[:alert]).to eq("You are not a participant in this session.")
      end
    end

    context "as a non-host instructor who has not joined" do
      before { log_in(other_instructor) }

      it "redirects to the join page" do
        get :show, params: { id: live_session.id }

        expect(response).to redirect_to(join_session_path)
      end
    end

    context "as a student who has not joined" do
      before { log_in(outsider) }

      it "redirects to the join page" do
        get :show, params: { id: live_session.id }

        expect(response).to redirect_to(join_session_path)
        expect(flash[:alert]).to eq("You are not a participant in this session.")
      end
    end

    context "rendered page" do
      render_views

      it "shows the host an End session button and no Leave session button" do
        log_in(host)
        get :show, params: { id: live_session.id }

        expect(response.body).to include("End session")
        expect(response.body).not_to include("Leave session")
      end

      it "shows a TA a Leave session button and no End session button" do
        live_session.join(ta, "7876")
        log_in(ta)
        get :show, params: { id: live_session.id }

        expect(response.body).to include("Leave session")
        expect(response.body).not_to include("End session")
      end

      it "lists only students in the participant table" do
        live_session.join(student, "7876")
        live_session.join(ta, "7876")
        log_in(host)
        get :show, params: { id: live_session.id }

        table = response.body[/<table.*?<\/table>/m]
        expect(table).to include("Alice Student")
        expect(table).not_to include("Theo TA")
      end

      it "shows the summary link to the host once the session has ended" do
        live_session.end
        log_in(host)
        get :show, params: { id: live_session.id }

        expect(response.body).to include("View session summary")
      end

      it "hides the summary link from a TA once the session has ended" do
        live_session.join(ta, "7876")
        live_session.end
        log_in(ta)
        get :show, params: { id: live_session.id }

        expect(response.body).to include("Session has ended.")
        expect(response.body).not_to include("View session summary")
      end

      it "does not link students back to question sets" do
        live_session.join(student, "7876")
        log_in(student)
        get :show, params: { id: live_session.id }

        expect(response.body).not_to include("Back to question sets")
      end
    end
  end

  describe "GET #new_join" do
    it "renders the join page for a logged-in user" do
      log_in(student)
      get :new_join

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #join" do
    it "adds a student with the correct code and redirects to the session" do
      log_in(student)
      post :join, params: { session_code: "7876" }

      expect(response).to redirect_to(session_path(live_session))
      expect(flash[:notice]).to eq("Joined session")
      expect(live_session.participants.reload).to include(student)
    end

    it "adds a TA with the correct code and redirects to the session" do
      log_in(ta)
      post :join, params: { session_code: "7876" }

      expect(response).to redirect_to(session_path(live_session))
      expect(live_session.participants.reload).to include(ta)
    end

    it "does not add the same user twice" do
      log_in(ta)
      post :join, params: { session_code: "7876" }
      post :join, params: { session_code: "7876" }

      expect(live_session.participants.reload.where(id: ta.id).count).to eq(1)
    end

    it "rejects a wrong code" do
      log_in(student)
      post :join, params: { session_code: "9999" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(flash[:alert]).to eq("Invalid session code")
      expect(live_session.participants.reload).not_to include(student)
    end

    it "rejects a blank code" do
      log_in(student)
      post :join, params: { session_code: "" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(flash[:alert]).to eq("Invalid session code")
    end

    it "rejects an ended session" do
      live_session.end
      log_in(student)
      post :join, params: { session_code: "7876" }

      expect(response).to have_http_status(:unprocessable_content)
      expect(flash[:alert]).to eq("Session has ended")
      expect(live_session.participants.reload).not_to include(student)
    end
  end

  describe "POST #end_session" do
    it "lets the host end the session and redirects to the summary" do
      log_in(host)
      post :end_session, params: { id: live_session.id }

      expect(response).to redirect_to(summary_session_path(live_session))
      expect(flash[:notice]).to eq("Session ended")
      expect(live_session.reload).to be_ended
    end

    it "tells the host when the session had already ended" do
      live_session.end
      log_in(host)
      post :end_session, params: { id: live_session.id }

      expect(response).to redirect_to(summary_session_path(live_session))
      expect(flash[:notice]).to eq("Session has already ended")
    end

    it "does not let a TA end the session" do
      live_session.join(ta, "7876")
      log_in(ta)
      post :end_session, params: { id: live_session.id }

      expect(response).to redirect_to(join_session_path)
      expect(flash[:alert]).to eq("You are not authorized to do that.")
      expect(live_session.reload).to be_active
    end

    it "does not let a non-host instructor end the session" do
      live_session.join(other_instructor, "7876")
      log_in(other_instructor)
      post :end_session, params: { id: live_session.id }

      expect(response).to redirect_to(join_session_path)
      expect(live_session.reload).to be_active
    end

    it "does not let a student end the session" do
      live_session.join(student, "7876")
      log_in(student)
      post :end_session, params: { id: live_session.id }

      expect(response).to redirect_to(join_session_path)
      expect(live_session.reload).to be_active
    end
  end

  describe "GET #summary" do
    it "shows the host the summary once the session has ended" do
      live_session.join(student, "7876")
      live_session.end
      log_in(host)
      get :summary, params: { id: live_session.id }

      expect(response).to have_http_status(:ok)
      expect(assigns(:summary)).to eq(live_session.reload.session_summary)
    end

    it "sends the host back to the session while it is still active" do
      log_in(host)
      get :summary, params: { id: live_session.id }

      expect(response).to redirect_to(session_path(live_session))
      expect(flash[:alert]).to eq("End the session to see its summary.")
    end

    it "sends a TA who joined back to the session" do
      live_session.join(ta, "7876")
      live_session.end
      log_in(ta)
      get :summary, params: { id: live_session.id }

      expect(response).to redirect_to(session_path(live_session))
      expect(flash[:alert]).to eq("You are not authorized to do that.")
    end

    it "sends a non-host instructor who joined back to the session" do
      live_session.join(other_instructor, "7876")
      live_session.end
      log_in(other_instructor)
      get :summary, params: { id: live_session.id }

      expect(response).to redirect_to(session_path(live_session))
      expect(flash[:alert]).to eq("You are not authorized to do that.")
    end

    it "sends a student who joined back to the session" do
      live_session.join(student, "7876")
      live_session.end
      log_in(student)
      get :summary, params: { id: live_session.id }

      expect(response).to redirect_to(session_path(live_session))
    end

    it "sends someone who never joined to the join page" do
      live_session.end
      log_in(outsider)
      get :summary, params: { id: live_session.id }

      expect(response).to redirect_to(join_session_path)
      expect(flash[:alert]).to eq("You are not authorized to do that.")
    end

    it "counts only students as participants" do
      live_session.join(student, "7876")
      live_session.join(ta, "7876")
      live_session.end
      log_in(host)
      get :summary, params: { id: live_session.id }

      expect(assigns(:summary)["participant_count"]).to eq(1)
    end
  end

  describe "POST #leave" do
    it "ends the session when the host leaves" do
      log_in(host)
      post :leave, params: { id: live_session.id }

      expect(response).to redirect_to(question_sets_path)
      expect(flash[:notice]).to eq("Session ended.")
      expect(live_session.reload).to be_ended
    end

    it "lets a TA leave without ending the session" do
      live_session.join(ta, "7876")
      log_in(ta)
      post :leave, params: { id: live_session.id }

      expect(response).to redirect_to(join_session_path)
      expect(flash[:notice]).to eq("You have left the session.")
      expect(live_session.reload).to be_active
    end

    it "lets a non-host instructor leave without ending the session" do
      live_session.join(other_instructor, "7876")
      log_in(other_instructor)
      post :leave, params: { id: live_session.id }

      expect(response).to redirect_to(join_session_path)
      expect(flash[:notice]).to eq("You have left the session.")
      expect(live_session.reload).to be_active
    end

    it "lets a student leave without ending the session" do
      live_session.join(student, "7876")
      log_in(student)
      post :leave, params: { id: live_session.id }

      expect(response).to redirect_to(join_session_path)
      expect(live_session.reload).to be_active
    end
  end
end