class Session < ApplicationRecord
  STATUSES = %w[active ended].freeze

  belongs_to :host, class_name: "User", foreign_key: :host_id
  has_and_belongs_to_many :participants,
                          class_name: "User",
                          join_table: "session_participants",
                          association_foreign_key: "user_id"

  validates :question_set_id, presence: true
  validates :host_id, presence: true
  validates :code, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  def self.start(question_set_id:, host:)
    create!(
      question_set_id: question_set_id,
      host: host,
      code: generate_unique_code,
      status: "active",
      summary: {}
    )
  end

  def self.generate_unique_code
    loop do
      code = format("%04d", SecureRandom.random_number(10_000))
      break code unless exists?(code: code)
    end
  end

  def active?
    status == "active"
  end

  def ended?
    status == "ended"
  end

  # Ends the session and stores a summary snapshot.
  def end
    return session_summary if ended?

    update!(status: "ended", summary: build_summary)
    session_summary
  end

  # Adds a user when the code matches an active session.
  # Returns :ok, :invalid_code, or :ended.
  def join(user, submitted_code)
    return :ended if ended?
    return :invalid_code if submitted_code.blank? || submitted_code.to_s != code.to_s

    participants << user unless participants.include?(user)
    :ok
  end

  def send_live_feedback(student, content)
    return :ended if ended?
    return :not_participant unless participants.include?(student)
    return :blank if content.blank?

    {
      session_id: id,
      to_user_id: student.id,
      content: content,
      delivered: true
    }
  end

  def allow_resubmission(student, question_id)
    return false if ended?
    return false unless participants.include?(student)

    true
  end

  def session_summary
    summary.presence || { "answered" => 0, "most_missed" => [] }
  end

  private

  def build_summary
    {
      "answered" => 0,
      "most_missed" => [],
      "participant_count" => participants.count
    }
  end
end
