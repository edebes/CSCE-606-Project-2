class LoginsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip)
    if user&.authenticate(params[:password].to_s)
      session[:user_id] = user.id
      redirect_to question_sets_path, notice: "Logged in"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    # Session.where(host_id: current_user.id, status: "active").find_each(&:end) if current_user
    reset_session
    redirect_to login_path, notice: "Logged out"
  end
end
