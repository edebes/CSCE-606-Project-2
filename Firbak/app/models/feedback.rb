class Feedback < ActiveRecord::Base
  belongs_to :session
  belongs_to :to_user, class_name: 'User'
  belongs_to :from_user, class_name: 'User'
  belongs_to :question

  validates :session, presence: true
  validates :to_user, presence: true
  validates :from_user, presence: true
  validates :question, presence: true
  validates :content, presence: true

  def deliver
    # Implement later when implementing JavaScript/WebSocket functionality
  end
end