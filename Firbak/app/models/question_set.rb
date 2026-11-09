class QuestionSet < ActiveRecord::Base
  validates :title, presence: true
  validates :owner_id, presence: true
  has_many :questions
end
