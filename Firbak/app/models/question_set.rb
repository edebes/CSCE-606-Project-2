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

  def launch_session()
    # session.start() ?
    # launching a session from a question set already works
    # so it might not be needed here?
  end

  def questions()
    questions
  end
end
