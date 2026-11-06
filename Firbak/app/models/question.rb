class Question < ApplicationRecord
  validates :body, presence: true
  validates :number, presence: true
  
  has_many :choices

  def add_choice(body:, correct:, feedback: nil)
    choices.create(body: body, correct: correct, feedback: feedback)
  end

  def remove_choice(choice)
    choices.destroy(choice)
  end

  def correct_choice
    choices.find_by(correct: true)
  end
end
