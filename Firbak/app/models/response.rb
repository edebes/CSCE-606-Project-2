class Response < ApplicationRecord
    belongs_to :session_id, class_name: "Session", foreign_key: :session_id
    belongs_to :user_id, class_name: "User", foreign_key: :user_id
    belongs_to :question_id, class_name: "Question", foreign_key: :question_id
    belongs_to :choice_id, class_name: "Choice", foreign_key: :choice_id

    validates :session_id, presence: true
    validates :user_id, presence: true
    validates :question_id, presence: true
    validates :choice_id, presence: true
end
