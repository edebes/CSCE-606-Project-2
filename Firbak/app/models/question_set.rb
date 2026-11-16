class QuestionSet < ActiveRecord::Base
  validates :title, presence: true
  validates :owner, presence: true

  has_many :questions
  has_and_belongs_to_many :courses
  belongs_to :owner, class_name: 'User'

  def add_question(question)
    questions.create(question)
  end

  def remove_question(question)
    questions.destroy(question)
  end
end
