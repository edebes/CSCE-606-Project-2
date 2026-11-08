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

  describe role? do
    it 'returns the role of the user' do
      user = described_class.find_by(user_id: 12345)
      expect(user.role?).to eq('student')
    end

    it 'does not return the role of the user if the user does not exist' do
      user = described_class.find_by(user_id: 99999)
      expect(user).to be_nil
    end
  end

  describe can_manage_sets? do
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

  describe can_give_live_feedback? do
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
end