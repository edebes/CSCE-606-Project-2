class Choice < ApplicationRecord
  def feedback_for_selection
    self.feedback
  end
end
