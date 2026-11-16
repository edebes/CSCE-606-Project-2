class SessionsController < ApplicationController
  before_action :require_login

  def show
    @session = Session.find(params[:id])
    if @session.host_id == current_user.id
      @host_view = true
    elsif @session.participants.include?(current_user)
      @current_question = @session.current_question_for(current_user) unless @session.ended?
    else
      redirect_to join_session_path, alert: "You are not a participant in this session."
      return
    end
  end

  def new_join
  end

  def join
    code = params[:session_code].to_s
    live_session = Session.find_by(code: code)

    if live_session.nil?
      flash.now[:alert] = "Invalid session code"
      render :new_join, status: :unprocessable_entity
      return
    end

    case live_session.join(current_user, code)
    when :ok
      redirect_to session_path(live_session), notice: "Joined session"
    when :invalid_code
      flash.now[:alert] = "Invalid session code"
      render :new_join, status: :unprocessable_entity
    when :ended
      flash.now[:alert] = "Session has ended"
      render :new_join, status: :unprocessable_entity
    else
      flash.now[:alert] = "Invalid session code"
      render :new_join, status: :unprocessable_entity
    end
  end

  def end_session
    @session = Session.find(params[:id])
    if @session.host_id != current_user.id
      redirect_to root_path, alert: "You are not authorized to do that."
      return
    end

    if @session.ended?
      redirect_to session_path(@session), notice: "Session has already ended."
      return
    end
    @session.end
    redirect_to session_path(@session), notice: "Session ended"
  end

  def leave
    @session = Session.find(params[:id])
    if @session.host_id == current_user.id
      @session.end
      redirect_to question_sets_path, notice: "Session ended."
    else
      redirect_to join_session_path, notice: "You have left the session."
    end
  end

  private

  def require_host
    @session = Session.find(params[:id])
    unless @session.host_id == current_user.id
      redirect_to root_path, alert: "You are not authorized to perform this action."
    end
  end
end
