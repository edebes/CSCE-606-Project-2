class User < ActiveRecord::Base
  # validations: false keeps existing User specs working; login still uses authenticate
  # when password_digest is present.
  has_secure_password validations: false

  ROLES = %w[instructor ta student].freeze

  has_many :sessions, foreign_key: "host_id", dependent: :destroy
  has_many :question_sets, foreign_key: "owner_id", dependent: :destroy
  has_many :responses, dependent: :destroy
  has_and_belongs_to_many :joined_sessions,
                          class_name: "Session",
                          join_table: "session_participants",
                          association_foreign_key: "session_id"
  has_many :course_memberships, dependent: :destroy
  has_many :courses, through: :course_memberships


  # "John@TAMU.edu " and "john@tamu.edu" are the same account, for sign-up and login.
  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: ROLES }

  def role?()
    self.role
  end

  def can_manage_sets?()
    self.role == "instructor"
  end

  def can_give_live_feedback?()
    self.role == "instructor" || self.role == "ta"
  end

  def struggling?(session)
    return false if session.ended?

    current_question = session.current_question_for(self)
    return false if current_question.nil?
    responses = session.responses.where(user_id: self.id, question_id: current_question.id)
    return false if responses.empty?

    return responses.last.correct == false
  end
end