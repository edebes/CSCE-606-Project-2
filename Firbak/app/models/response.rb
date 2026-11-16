class Response < ApplicationRecord
    belongs_to :session
    belongs_to :user
    belongs_to :question
    belongs_to :choice
    before_validation { self.correct = choice&.correct if correct.nil? }
end
