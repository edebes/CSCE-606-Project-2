class QuestionSetsController < ApplicationController
  before_action :require_login
  before_action :set_question_set, only: [:edit, :update, :launch_session]
  before_action :require_owner, only: [:edit, :update]

  def index
    @question_sets = if current_user.can_manage_sets?
                       QuestionSet.where(owner: current_user).order(:title)
                     else
                       QuestionSet.none
                     end
  end
  def edit

  end

  def update
    if @question_set.update(question_set_params)
      redirect_to question_sets_path, notice: "Question set updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def launch_session
    unless current_user.can_manage_sets? && @question_set.owner == current_user
      flash[:alert] = "You are not authorized to do that"
      redirect_to question_sets_path and return
    end

    if @question_set.questions.none?
      flash[:alert] = "Add at least one question before starting a session"
      redirect_to question_sets_path and return
    end

    live_session = Session.start(question_set_id: @question_set.id, host: current_user)
    redirect_to session_path(live_session), notice: "Session started"
  end

  private

  def set_question_set
    @question_set = QuestionSet.find(params[:id])
  end

  # Only the instructor who owns a set may edit it.
  def require_owner
    return if @question_set.owner == current_user

    redirect_to question_sets_path, alert: "You are not authorized to do that"
  end

  def question_set_params
    params.require(:question_set).permit(:title)
  end
end

