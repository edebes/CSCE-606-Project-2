class Response < ApplicationRecord
    belongs_to :session
    belongs_to :user
    belongs_to :question
    belongs_to :choice
    before_validation { self.correct = choice&.correct if correct.nil? }


# #28: the instructor's pre-programmed feedback for the chosen wrong answer,
# or nil when the answer is right or no feedback was written for that choice.
    def feedback
        return nil if correct
        
        choice&.feedback_for_selection.presence
    end
end

