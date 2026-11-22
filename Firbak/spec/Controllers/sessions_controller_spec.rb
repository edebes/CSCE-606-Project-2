require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  before(:each) do
    if User.where(id: 500).empty?
      User.create(
        id: 500,
        name: "John",
        email: "john@tamu.edu",
        role: "student"
      )
    end
    if User.where(id: 600).empty?
      User.create(
        id: 600,
        name: "Anne",
        email: "anne@tamu.edu",
        role: "instructor"
      )
    end
    if QuestionSet.where(id: 1000).empty?
      QuestionSet.create(
        id: 1000,
        title: "Math 101",
        owner_id: 600
      )
    end
    if Question.where(id: 2000).empty?
      Question.create(
        id: 2000,
        number: 1,
        body: "What is 2 + 2?",
        
        question_set_id: 1000
      )
    end
    if Choice.where(id: 1).empty?
      Choice.create(
        id: 1,
        body: "4",
        correct: true,
        question_id: 2000
      )
    end
    if Choice.where(id: 2).empty?
      Choice.create(
        id: 2,
        body: "5",
        correct: false,
        question_id: 2000
      )
    end
    if Session.where(id: 3000).empty?
      Session.create(
        id: 3000,
        host_id: 600,
        question_set_id: 1000,
        code: "ABC123",
        status: "active"
      )
    end
  end

  describe 'POST #show' do
    it 'returns the session details for a valid session code' do
      # whoever wrote these should implement them
    end
  end


  describe 'POST #join' do
    it 'allows a user to join a session with a valid code' do
      # whoever wrote these should implement them
      expect(response).to have_http_status(:success)
    end

    it 'does not allow a user to join a session with an invalid code' do
      session[:user_id] = 500
      post :join, params: { session_code: "WRONG1" }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'POST #end_session' do
    it 'allows an instructor to end a session' do
      # work in progress
    end
  end
end