require 'rails_helper'

RSpec.describe Response, type: :model do
  before(:each) do
    user = User.find_by(user_id: 12345)
    user ||= User.create(user_id: 12345, name: 'John Doe', email: 'john.doe@tamu.edu', role: 'student')

    instructor = User.find_by(user_id: 24680)
    instructor ||= User.create(user_id: 24680, name: 'Anne Smith', email: 'anne.smith@tamu.edu', role: 'instructor')

    question_set = QuestionSet.find_by(title: 'Sample Question Set')
    question_set ||= QuestionSet.create(title: 'Sample Question Set', owner_id: instructor.id)

    question = Question.find_by(body: '3 * 2 = ?')
    question ||= Question.create(body: '3 * 2 = ?', number: 1, question_set_id: question_set.id)

    choice1 = Choice.find_by(body: '6')
    choice1 ||= Choice.create(body: '6', correct: true, question_id: question.id)

    choice2 = Choice.find_by(body: '5')
    choice2 ||= Choice.create(body: '5', correct: false, question_id: question.id)

    session = Session.find_by(host_id: instructor.id, question_set_id: question_set.id)
    session ||= Session.create(host_id: instructor.id, question_set_id: question_set.id, code: 'ABC123', status: 'active')
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      user = User.find_by(user_id: 12345)
      question = Question.find_by(body: '3 * 2 = ?')
      choice = Choice.find_by(body: '6')
      instructor = User.find_by(user_id: 24680)
      session = Session.find_by(host_id: instructor.id)

      response = described_class.new(session: session, user: user, question: question, choice: choice)
      expect(response).to be_valid
    end

    it 'is invalid without a session_id' do
      user = User.find_by(user_id: 12345)
      question = Question.find_by(body: '3 * 2 = ?')
      choice = Choice.find_by(body: '6')

      response = described_class.new(session: nil, user: user, question: question, choice: choice)
      expect(response).not_to be_valid
    end

    it 'is invalid without a user_id' do
      question = Question.find_by(body: '3 * 2 = ?')
      choice = Choice.find_by(body: '6')
      session = Session.find_by(host_id: 24680)

      response = described_class.new(session: session, user: nil, question: question, choice: choice)
      expect(response).not_to be_valid
    end

    it 'is invalid without a question_id' do
      user = User.find_by(user_id: 12345)
      choice = Choice.find_by(body: '6')
      session = Session.find_by(host_id: 24680)

      response = described_class.new(session: session, user: user, question: nil, choice: choice)
      expect(response).not_to be_valid
    end

    it 'is invalid without a choice_id' do
      user = User.find_by(user_id: 12345)
      question = Question.find_by(body: '3 * 2 = ?')
      session = Session.find_by(host_id: 24680)

      response = described_class.new(session: session, user: user, question: question, choice: nil)
      expect(response).not_to be_valid
    end
  end
end
