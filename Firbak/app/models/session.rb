class Session < ApplicationRecord
  STATUSES = %w[active ended].freeze

  belongs_to :host, class_name: "User", foreign_key: :host_id
  belongs_to :question_set
  has_and_belongs_to_many :participants,
                          class_name: "User",
                          join_table: "session_participants",
                          association_foreign_key: "user_id"
  has_many :responses, dependent: :destroy

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
    return :not_participant unless participants.where(role: "student").include?(student)
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

  def ordered_questions
    question_set.questions.order(:number)
  end

  def current_question_for(student)
    done = responses.where(user_id: student.id, correct: true).select(:question_id)
    ordered_questions.where.not(id: done).first
  end

  def submit_response(student, question, choice)
    return :ended if ended?
    return :not_participant unless participants.include?(student)
    return :not_student unless student.role == "student"
    return :invalid_question unless question_set.questions.include?(question)
    return :invalid_choice unless question.choices.include?(choice)

    response = Response.create!(
      session: self,
      user: student,
      question: question,
      choice: choice,
      correct: choice.correct
    )
    response
  end

  def progress_for(student)
    total_questions = question_set.questions.count
    answered_questions = responses.where(user_id: student.id, correct: true).distinct.count(:question_id)
    {
      total_questions: total_questions,
      answered_questions: answered_questions,
      progress_percentage: total_questions.zero? ? 0 : (answered_questions.to_f / total_questions * 100).round(2)
    }
  end

  private

  # #32: counts each student's FIRST attempt per question, so getting it right
  # later doesn't hide what the class got wrong the first time.

  def build_summary

    first_attempts = responses.order(:created_at, :id)
                    .group_by{ |response| [response.user_id, response.question_id] }
                    .values.map(&:first)
    by_question = first_attempts.group_by(&:question_id)

    questions = ordered_questions.includes(:choices).map do |question|
      question_responses = by_question.fetch(question.id, [])
      correct = question_responses.count(&:correct)

    {
      "question_id" => question.id,
        "number" => question.number,
        "body" => question.body,
        "answered" => question_responses.size,
        "correct" => correct,
        "missed" => question_responses.size - correct,
        "choices" => question.choices.sort_by(&:id).map do |choice|
          {
            "body" => choice.body,
            "correct" => choice.correct,
            "count" => question_responses.count { |response| response.choice_id == choice.id }
          }
        end
      }
    end

    most_missed = questions.select { |question| question["answered"].positive? }
                           .sort_by { |question| [ -question["missed"], question["number"].to_i ] }

    {
      "answered" => first_attempts.size,
      "participant_count" => participants.where(role: "student").count,
      "questions" => questions,
      "most_missed" => most_missed.map { |question| question.slice("question_id", "number", "body", "answered", "missed") }
    }
  end
end

