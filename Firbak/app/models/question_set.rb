class QuestionSet < ApplicationRecord
  belongs_to :owner, class_name: "User", foreign_key: :owner_id
  has_many :questions, dependent: :destroy
  has_many :sessions, dependent: :destroy

  validates :title, presence: true
  validates :owner_id, presence: true

  def launch_session(host: owner)
    raise ArgumentError, "Add at least one question before starting a session" if questions.none?

    Session.start(question_set_id: id, host: host)
  end
end
