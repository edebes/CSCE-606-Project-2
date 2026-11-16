class SessionsController < ApplicationController
  before_action :require_login

  def show
    @session = Session.find(params[:id])
    redirect_to root_path, alert: "Session not found" and return unless @session
    case current_user.role?
    when 'instructor'
      unless @session.host_id == current_user.id
        redirect_to root_path, alert: "You are not authorized to view this session."
      end
    when 'ta', 'student'
      unless @session.participants.include?(current_user)
        redirect_to root_path, alert: "You are not authorized to view this session."
      end
      current_question = @session.current_question_for(current_user)
      redirect_to session_path(@session, current_question)
    else
      redirect_to root_path, alert: "You are not authorized to view this session."
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
      redirect_to root_path, alert: "You are not authorized to end this session."
      return
    end

    if @session.ended?
      redirect_to session_dashboard_path(@session), notice: "Session has already ended."
      return
    end
    @session.end
    redirect_to session_dashboard_path(@session), notice: "Session ended"
  end

  def leave
    @session = Session.find(params[:id])
    if @session.participants.include?(current_user)
      @session.participants.delete(current_user)
      redirect_to root_path, notice: "You have left the session."
    else
      redirect_to root_path, alert: "You are not a participant in this session."
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
