class FeedbacksController < ApplicationController
  before_action :require_login
  before_action :set_session, only: %i[new send_feedback]
  before_action :set_recipient, only: %i[new send_feedback]
  before_action :authorize_feedback_sender!, only: %i[new send_feedback]

  # GET /sessions/:session_id/feedback
  def new
    @feedback = Feedback.new
    @question = @session
                .question_set
                .questions
                .find_by(
                  number: get_feedback_params[:question]
                )
  end

  # POST /sessions/:session_id/feedback
  def send_feedback
    #session = Session.find(feedback_params[:session_id])
    #recipient = User.find(feedback_params[:to])
    question = @session.question_set.questions.find_by!(
      number: post_feedback_params[:question]
    )

    @feedback = Feedback.new(
      session: @session, 
      to_user: @recipient, 
      from_user: current_user, 
      question: question,
      content: post_feedback_params[:content]
    )

    respond_to do |format|
      if @feedback.save
        format.html { redirect_to session_path(@feedback.session), notice: "Feedback was sent successfully" }
      else
        format.html { render :new, status: :unprocessable_entity}
      end
    end
  end

  def set_session
    @session = Session.find(params[:session_id])
  end

  def set_recipient
    @recipient = User.find(params[:to])
  end

  def authorize_feedback_sender!
    if @session.ended?
      redirect_to session_path(@session), alert: "Session has ended"
      return
    end

    allowed = current_user.can_give_live_feedback? &&
              (@session.host_id == current_user.id ||
               @session.participants.exists?(id: current_user.id))
    
    return if allowed

    redirect_to session_path(@session), alert: "You are not authorized to send feedback"
  end

  def post_feedback_params
    top_level = params.permit(:session_id, :question, :to)
    nested = params.expect(feedback: [:content])
    nested.merge(top_level)
  end

  def get_feedback_params
    params.permit(:session_id, :question, :to)
  end
end