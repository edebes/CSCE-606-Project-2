class User < ActiveRecord::Base
  has_many :sessions, foreign_key: "host_id", dependent: :destroy
  has_many :question_sets, foreign_key: "author_id", dependent: :destroy
  has_many :course_memberships, dependent: :destroy
  has_many :courses, through: :course_memberships

  validates :user_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: %w[instructor ta student] }

  def role?()
    self.role
  end

  def can_manage_sets?()
    self.role == "instructor"
  end

  def can_give_live_feedback?()
    self.role == "instructor" || self.role == "ta"
  end
end