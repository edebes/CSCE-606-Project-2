require "rails_helper"

RSpec.describe FeedbacksController, type: :controller do
  render_views

  let(:instructor) { create_user(role: "instructor", name: "Anne") }
  let(:student) { create_user(role: "student", name: "John") }
  let(:question_set) { QuestionSet.create!(title: "Math", owner: instructor) }
  let(:question) do
    Question.create!(number: 1, body: "What is 2 + 2?", question_set: question_set)
  end
  let(:live_session) do
    Session.create!(
      question_set: question_set,
      host: instructor,
      code: Session.generate_unique_code,
      status: "active"
    )
  end

  before do
    session[:user_id] = instructor.id
  end

  describe "GET #new" do
    it "renders the feedback form for the selected student and question" do
      get :new, params: {
        session_id: live_session.id,
        question: question.number,
        to: student.user_id
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Send Feedback to John")
      expect(response.body).to include("Feedback for Question 1")
    end

    it "assigns the correct question based on question number" do
      get :new, params: {
        session_id: live_session_id,
        question: question.number,
        to: student.user_id
      }

      expect(assigns(:question)).to eq(question)
    end
  end

  describe "POST #send_feedback" do
    let(:feedback_params) do
      {
        session_id: live_session.id,
        question: question.number,
        to: student.user_id,
        feedback: { content: "Try again" }
      }
    end

    it "creates feedback for the selected student and question" do
      expect do
        post :send_feedback, params: feedback_params
      end.to change(Feedback, :count).by(1)

      feedback = Feedback.order(:id).last
      expect(feedback).to have_attributes(
        session_id: live_session.id,
        to_user_id: student.id,
        from_user_id: instructor.id,
        question_id: question.id,
        content: "Try again"
      )
      expect(response).to redirect_to(session_path(live_session))
    end

    it "does not create feedback when the sender is not authorized" do
      session[:user_id] = student.id

      expect do
        post :send_feedback, params: feedback_params
      end.not_to change(Feedback, :count)

      expect(response).to redirect_to(session_path(live_session))
      expect(flash[:alert]).to eq("You are not authorized to send feedback")
    end

    it "does not create feedback after the session has ended" do
      live_session.update!(status: "ended")

      expect do
        post :send_feedback, params: feedback_params
      end.not_to change(Feedback, :count)

      expect(response).to redirect_to(session_path(live_session))
      expect(flash[:alert]).to eq("Session has ended")
    end
  end

  private

  def create_user(role:, name:)
    user_id = User.maximum(:user_id).to_i + 1
    User.create!(
      user_id: user_id,
      name: name,
      email: "feedback-#{user_id}@example.com",
      role: role
    )
  end
end
