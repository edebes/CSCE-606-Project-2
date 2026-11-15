require 'rails_helper'

RSpec.describe Response, type: :model do
  before(:all) do
    user = User.find_by(user_id: 12345)
    user ||= User.create(user_id: 12345, name: 'John Doe', email: 'john.doe@tamu.edu', role: 'student')

    instructor = User.find_by(user_id: 24680)
    instructor ||= User.create(user_id: 24680, name: 'Anne Smith', email: 'anne.smith@tamu.edu', role: 'instructor')

    question_set = QuestionSet.find_by(name: 'Sample Question Set')
    question_set ||= QuestionSet.create(name: 'Sample Question Set', author: instructor)

    question = Question.find_by(body: '3 * 2 = ?')
    question ||= Question.create(body: '3 * 2 = ?', question_set: question_set)

    choice1 = Choice.find_by(body: '6')
    choice1 ||= Choice.create(body: '6', correct: true, question: question)

    choice2 = Choice.find_by(body: '5')
    choice2 ||= Choice.create(body: '5', correct: false, question: question)

    session = Session.find_by(host: instructor)
    session ||= Session.create(host: instructor)
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.find_by(user_id: 12345)
      question = Question.find_by(body: '3 * 2 = ?')
      choice = Choice.find_by(body: '6')
      session = Session.find_by(host: User.find_by(user_id: 24680))

      response = described_class.new(session_id: session.id, user_id: user.id, question_id: question.id, choice_id: choice.id)
      expect(response).to be_valid
    end

    it 'is invalid without a session_id' do
      user = User.find_by(user_id: 12345)
      question = Question.find_by(body: '3 * 2 = ?')
      choice = Choice.find_by(body: '6')

      response = described_class.new(session_id: nil, user_id: user.id, question_id: question.id, choice_id: choice.id)
      expect(response).not_to be_valid
    end

    it 'is invalid without a user_id' do
      question = Question.find_by(body: '3 * 2 = ?')
      choice = Choice.find_by(body: '6')
      session = Session.find_by(host: User.find_by(user_id: 24680))

      response = described_class.new(session_id: session.id, user_id: nil, question_id: question.id, choice_id: choice.id)
      expect(response).not_to be_valid
    end

    it 'is invalid without a question_id' do
      user = User.find_by(user_id: 12345)
      choice = Choice.find_by(body: '6')
      session = Session.find_by(host: User.find_by(user_id: 24680))

      response = described_class.new(session_id: session.id, user_id: user.id, question_id: nil, choice_id: choice.id)
      expect(response).not_to be_valid
    end

    it 'is invalid without a choice_id' do
      user = User.find_by(user_id: 12345)
      question = Question.find_by(body: '3 * 2 = ?')
      session = Session.find_by(host: User.find_by(user_id: 24680))

      response = described_class.new(session_id: session.id, user_id: user.id, question_id: question.id, choice_id: nil)
      expect(response).not_to be_valid
    end
  end
end
