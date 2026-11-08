class User < ApplicationRecord
  has_secure_password

  has_many :course_memberships, dependent: :destroy
  has_many :courses, through: :course_memberships
  has_many :question_sets, foreign_key: :owner_id, dependent: :destroy
  has_many :hosted_sessions, class_name: "Session", foreign_key: :host_id, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :role, presence: true

  def instructor?
    role.to_s.downcase == "instructor"
  end

  def ta?
    role.to_s.downcase == "ta"
  end

  def student?
    role.to_s.downcase == "student"
  end

  def can_manage_sets?
    instructor?
  end

  def can_host_session?
    instructor?
  end
end
