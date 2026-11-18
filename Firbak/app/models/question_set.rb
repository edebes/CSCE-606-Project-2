class QuestionSet < ActiveRecord::Base
  validates :title, presence: true
  validates :owner, presence: true

  # Sessions go first: their responses point at this set's questions and choices.
  has_many :sessions, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_and_belongs_to_many :courses
  belongs_to :owner, class_name: 'User'

  def add_question(question)
    questions.create(question)
  end

  def remove_question(question)
    questions.destroy(question)
  end
end
