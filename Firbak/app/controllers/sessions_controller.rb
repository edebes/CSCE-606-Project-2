class SessionsController < ApplicationController
  before_action :require_login

  def show
    @session = Session.find(params[:id])
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
end
