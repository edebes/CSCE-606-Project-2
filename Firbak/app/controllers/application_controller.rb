class ApplicationController < ActionController::Base
  # Rack::Test (Cucumber) is not a "modern browser"; keep this for real browsers only.
  allow_browser versions: :modern unless Rails.env.test?
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?

    flash[:alert] = "You must log in first"
    redirect_to login_path
  end

  def require_instructor
    return if current_user&.can_manage_sets?

    flash[:alert] = "You are not authorized to do that"
    redirect_back fallback_location: root_path
  end
end
