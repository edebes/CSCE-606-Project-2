# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  before(:all) do
    question = described_class.find_by(body: '2 x 3 = ?')
    question ||= described_class.create(body: '2 x 3 = ?', number: 1)

    if Choice.where(body: '6', question: question).empty?
      Choice.create(body: '6', question: question, correct: true)
    end

    if Choice.where(body: '5', question: question).empty?
      Choice.create(body: '5', question: question, correct: false, feedback: "You added instead of multiplied")
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      question = described_class.new(body: '10 + 5 = ?', number: 2)

      expect(question).to be_valid
    end

    it 'is invalid without a body' do
      question = described_class.new(body: nil, number: 3)

      expect(question).not_to be_valid
    end

    it 'is invalid without a number' do
      question = described_class.new(body: '8 / 4 = ?', number: nil)

      expect(question).not_to be_valid
    end
  end

  describe 'add_choice' do
    it 'actually adds the choice' do
      question = described_class.find_by(body: '2 x 3 = ?')
      choice = question.add_choice(body: '12', correct: false, feedback: 'You multipled by too much!')

      expect(question.choices.reload).to include(choice)

      choice.destroy
    end

    it 'rejects choices with empty bodies' do
      question = described_class.find_by(body: '2 x 3 = ?')
      choice = question.add_choice(body: nil, correct: false)

      expect(question.choices.reload).not_to include(choice)

      choice.destroy
    end

    it 'rejects choices without correctness' do
      question = described_class.find_by(body: '2 x 3 = ?')
      choice = question.add_choice(body: "7", correct: nil)

      expect(question.choices.reload).not_to include(choice)

      choice.destroy
    end
  end

  describe 'remove_choice' do
    it 'removes a found choice' do
      question = described_class.find_by(body: '2 x 3 = ?')
      choice = question.choices.create(body: '7', correct: false)

      expect {
        question.remove_choice(choice)
      }.to change(question.choices, :count).by(-1)
    end
  end

  describe 'choices' do
    it 'returns all choices associated with question' do
      question = described_class.find_by(body: '2 x 3 = ?')

      expect(question.choices.count).to be >= 2
      expect(question.choices).to include(question.choices.first)
    end

    it 'returns an empty list for a question with no choices' do
      question = described_class.create(body: '7 + 7 = ?', number: 99)

      expect(question.choices).to be_empty
    end

    it 'does not return choices not associated with the question' do
      question = described_class.find_by(body: '2 x 3 = ?')
      other_question = described_class.create(body: '9 + 1 = ?', number: 100)
      other_choice = other_question.choices.create(body: '10', correct: true)

      expect(question.choices).not_to include(other_choice)
    end
  end

  describe 'correct_choice' do
    it 'returns a correct choice for the answer' do
      question = described_class.find_by(body: '2 x 3 = ?')

      expect(question.correct_choice).to be_present
      expect(question.correct_choice.correct).to be true
    end

    it 'does not return a false choice for the answer' do
      question = described_class.find_by(body: '2 x 3 = ?')
      incorrect_choice = question.choices.find_by(body: '5')

      expect(question.correct_choice).not_to eq(incorrect_choice)
    end

    it 'returns nothing if question has no correct choices' do
      question = described_class.create(body: '8 + 2 = ?', number: 101)
      question.choices.create(body: '11', correct: false)

      expect(question.correct_choice).to be_nil
    end
  end
end
