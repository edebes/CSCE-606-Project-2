# Issue #62 - new users create their own (student) account.
class RegistrationsController < ApplicationController
  def new
    if logged_in?
      redirect_to root_path, notice: "You are already logged in."
      return
    end
    @user = User.new
  end

  def create
    # Role is never taken from the form: every new account is a student.
    # Instructors change roles from their own page (#64).
    @user = User.new(registration_params.merge(role: "student"))

    if @user.save(context: :registration)
      reset_session
      session[:user_id] = @user.id
      redirect_to join_session_path, notice: "Welcome, #{@user.name}! Your student account is ready."
    else
      flash.now[:alert] = "Please fix the problems below."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end