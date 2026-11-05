class Choice < ApplicationRecord
  validates :body, presence: true
  validates :correct, presence: true
  
  def feedback_for_selection
    self.feedback
  end
end
