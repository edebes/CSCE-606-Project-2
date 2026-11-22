require "rails_helper"

RSpec.describe LoginsController, type: :controller do
  def create_user!(attrs)
    password = "password123"
    User.create!(
      attrs.merge(
        password: password,
        password_confirmation: password
      )
    )
  end

  let!(:instructor) do
     User.find_by(email: "anne.login@tamu.edu") ||
       create_user!(name: "Anne Host", email: "anne.login@tamu.edu", role: "instructor")
  end

  let!(:ta) do
    User.find_by(email: "theo.login@tamu.edu") ||
      create_user!(name: "Theo TA", email: "theo.login@tamu.edu", role: "ta")
  end

  let!(:student) do
    User.find_by(email: "alice.login@tamu.edu") ||
      create_user!(name: "Alice Student", email: "alice.login@tamu.edu", role: "student")
  end

  describe "GET #new" do
    it "renders the login page" do
      get :new

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    def log_in_with(email, password = "password123")
      post :create, params: { email: email, password: password }
    end

    it "sends an instructor to their question sets" do
      log_in_with(instructor.email)

      expect(response).to redirect_to(question_sets_path)
      expect(flash[:notice]).to eq("Logged in")
      expect(session[:user_id]).to eq(instructor.id)
    end

    it "sends a TA to the join page" do
      log_in_with(ta.email)

      expect(response).to redirect_to(join_session_path)
      expect(flash[:notice]).to eq("Logged in")
      expect(session[:user_id]).to eq(ta.id)
    end

    it "sends a student to the join page" do
      log_in_with(student.email)

      expect(response).to redirect_to(join_session_path)
      expect(session[:user_id]).to eq(student.id)
    end

    it "ignores surrounding spaces and capital letters in the email" do
      log_in_with("  Alice.Login@Tamu.EDU ")

      expect(response).to redirect_to(join_session_path)
      expect(session[:user_id]).to eq(student.id)
    end

    it "rejects a wrong password" do
      log_in_with(student.email, "wrongpassword")

      expect(response).to have_http_status(:unprocessable_content)
      expect(flash[:alert]).to eq("Invalid email or password")
      expect(session[:user_id]).to be_nil
    end

    it "rejects an unknown email" do
      log_in_with("nobody.login@tamu.edu")

      expect(response).to have_http_status(:unprocessable_content)
      expect(flash[:alert]).to eq("Invalid email or password")
      expect(session[:user_id]).to be_nil
    end

    it "rejects a blank password" do
      log_in_with(student.email, "")

      expect(response).to have_http_status(:unprocessable_content)
      expect(session[:user_id]).to be_nil
    end
  end

  describe "POST #destroy" do
    let!(:question_set) do
      QuestionSet.find_by(title: "Week 5") ||
        QuestionSet.create!(title: "Week 5", owner: instructor)
    end

    let!(:live_session) do
      Session.find_by(question_set: question_set, host: instructor) ||
        Session.create!(question_set: question_set, host: instructor, code: "8102", status: "active", summary: {})
    end

    it "logs the user out and returns to the login page" do
      session[:user_id] = student.id
      post :destroy

      expect(response).to redirect_to(login_path)
      expect(flash[:notice]).to eq("Logged out")
      expect(session[:user_id]).to be_nil
    end

    it "ends the sessions an instructor is hosting" do
      session[:user_id] = instructor.id
      post :destroy

      expect(live_session.reload).to be_ended
    end

    it "does not end a session when a TA in it logs out" do
      live_session.join(ta, "8102")
      session[:user_id] = ta.id
      post :destroy

      expect(live_session.reload).to be_active
    end

    it "still works when nobody is logged in" do
      post :destroy

      expect(response).to redirect_to(login_path)
    end
  end
end