class SessionsController < ApplicationController
  before_action :require_login

  def show
    @session = Session.find(params[:id])
  end
end
