class Choice < ApplicationRecord
  validates :body, presence: true
  validates :correct, inclusion: { in: [true, false] }

  belongs_to :question
  has_many :responses, dependent: :destroy

  def feedback_for_selection
    self.feedback
  end
end
