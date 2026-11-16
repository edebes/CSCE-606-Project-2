# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  before(:all) do
    user_student = described_class.find_by(user_id: 12345)
    user_student ||= described_class.create(user_id: 12345, name: 'John Doe', email: 'john.doe@tamu.edu', role: 'student')

    user_instructor = described_class.find_by(user_id: 24680)
    user_instructor ||= described_class.create(user_id: 24680, name: 'Anne Smith', email: 'anne.smith@tamu.edu', role: 'instructor')

    user_ta = described_class.find_by(user_id: 13579)
    user_ta ||= described_class.create(user_id: 13579, name: 'Alfonzo Rebeiro', email: 'alfonzo.ribeiro@tamu.edu', role: 'ta')
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      user = described_class.new(user_id: 11111, name: 'Jane Doe', email: 'jane.doe@tamu.edu', role: 'student')
      expect(user).to be_valid
    end

    it 'is invalid without a user_id' do
      user = described_class.new(user_id: nil, name: 'Jane Doe', email: 'jane.doe@tamu.edu', role: 'student')
      expect(user).not_to be_valid
    end

    it 'is invalid without a name' do
      user = described_class.new(user_id: 11111, name: nil, email: 'jane.doe@tamu.edu', role: 'student')
      expect(user).not_to be_valid
    end

    it 'is invalid without an email' do
      user = described_class.new(user_id: 11111, name: 'Jane Doe', email: nil, role: 'student')
      expect(user).not_to be_valid
    end

    it 'is invalid without a role' do
      user = described_class.new(user_id: 11111, name: 'Jane Doe', email: 'jane.doe@tamu.edu', role: nil)
      expect(user).not_to be_valid
    end
  end

  describe 'role?' do
    it 'returns the role of the user' do
      user = described_class.find_by(user_id: 12345)
      expect(user.role?).to eq('student')
    end

    it 'does not return the role of the user if the user does not exist' do
      user = described_class.find_by(user_id: 99999)
      expect(user).to be_nil
    end
  end

  describe 'can_manage_sets?' do
    it 'returns true for an instructor' do
      user = described_class.find_by(user_id: 24680)
      expect(user.can_manage_sets?).to be true
    end

    it 'returns false for a student' do
      user = described_class.find_by(user_id: 12345)
      expect(user.can_manage_sets?).to be false
    end

    it 'returns false for a ta' do
      user = described_class.find_by(user_id: 13579)
      expect(user.can_manage_sets?).to be false
    end

    it 'returns false for a non-existent user' do
      user = described_class.find_by(user_id: 99999)
      expect(user).to be_nil
    end
  end

  describe 'can_give_live_feedback?' do
    it 'returns true for an instructor' do
      user = described_class.find_by(user_id: 24680)
      expect(user.can_give_live_feedback?).to be true
    end

    it 'returns true for a ta' do
      user = described_class.find_by(user_id: 13579)
      expect(user.can_give_live_feedback?).to be true
    end

    it 'returns false for a student' do
      user = described_class.find_by(user_id: 12345)
      expect(user.can_give_live_feedback?).to be false
    end

    it 'returns false for a non-existent user' do
      user = described_class.find_by(user_id: 99999)
      expect(user).to be_nil
    end
  end

  # describe 'struggling?' do # This function needs more time to implement, but is not necessary at the moment.
  #   let(:instructor) { User.find_by(user_id: 24680) }
  #   let(:question_set) { QuestionSet.find_by(title: 'Sample Question Set') || QuestionSet.create(title: 'Sample Question Set', owner_id: :instructor.id) }
  #   let(:question) { Question.find_by(body: '3 * 2 = ?') || Question.create(body: '3 * 2 = ?', number: 1, question_set_id: :question_set.id) }
  #   let(:choice1) { Choice.find_by(body: '6') || Choice.create(body: '6', correct: true, question_id: :question.id) }
  #   let(:choice2) { Choice.find_by(body: '5') || Choice.create(body: '5', correct: false, question_id: :question.id) }
  #   let(:session) { Session.find_by(host_id: :instructor.id, question_set_id: :question_set.id) || Session.create(host_id: :instructor.id, question_set_id: :question_set.id, code: 'ABC123', status: 'active') }

  #   it 'returns true if the user is struggling with the current question' do
  #     user = described_class.find_by(user_id: 12345)
  #     session = :session
  #     Response.create!(session_id: session, user_id: user, question_id: question, choice_id: choice2)
  #     expect(user.struggling?(session)).to be true
  #   end

  #   it 'returns false if the user is not struggling with the current question' do
  #     user = described_class.find_by(user_id: 12345)
  #     session = :session
  #     Response.create!(session_id: session, user_id: user_student, question_id: question, choice_id: choice1)
  #     expect(user.struggling?(session)).to be false
  #   end

  #   it 'returns false if the session has ended' do
  #     user = described_class.find_by(user_id: 12345)
  #     session = Session.create(host_id: :instructor.id, question_set_id: :question_set.id, code: 'DEF456', status: 'ended')
  #     expect(user.struggling?(session)).to be false
  #   end

    # it 'returns false if there is no current question for the user' do
    #   user = described_class.find_by(user_id: 12345)
    #   session = Session.find_by(host_id: 24680)
    #   expect(user.struggling?(session)).to be false
    # end

    # it 'returns false if there are no responses for the current question' do
    #   user = described_class.find_by(user_id: 12345)
    #   session = Session.find_by(host_id: 24680)
    #   expect(user.struggling?(session)).to be false
    # end
  # end
end