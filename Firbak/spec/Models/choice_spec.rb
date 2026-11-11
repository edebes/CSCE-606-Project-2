# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Choice, type: :model do
  before(:all) do
    question = Question.find_by(body: '2 x 3 = ?', number: 1)
    question ||= Question.create(body: '2 x 3 = ?', number: 1)

    if described_class.where(body: '6').empty?
      described_class.create(body: '6', correct: true, question: question)
    end

    if described_class.where(body: '5').empty?
      described_class.create(body: '5', correct: false, question: question, feedback: 'You added instead of multiplied')
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      choice = described_class.find_by(body: '6', correct: true)

      expect(choice).to be_valid
    end

    it 'is invalid without a body' do
      question = Question.find_by(body: '2 x 3 = ?', number: 1)
      choice = described_class.new(body: nil, correct: true, question: question)

      expect(choice).not_to be_valid
    end

    it 'is invalid without a correctness' do
      question = Question.find_by(body: '2 x 3 = ?', number: 1)
      choice = described_class.new(body: '6', correct: nil, question: question)

      expect(choice).not_to be_valid
    end
  end

  describe 'correct?' do
    it 'returns true for correct options' do
      option = described_class.find_by(body: '6')

      expect(option.correct?).to be true
    end

    it 'returns false for incorrect options' do
      option = described_class.find_by(body: '5')

      expect(option.correct?).to be false
    end
  end

  describe 'feedback_for_selection' do
    it 'returns feedback for choices with feedback' do
      option = described_class.find_by(body: '5')

      expect(option.feedback_for_selection).to eq('You added instead of multiplied')
    end

    it 'returns nothing for choices without feedback' do
      option = described_class.find_by(body: '6')

      expect(option.feedback_for_selection).to be_nil
    end
  end
end
