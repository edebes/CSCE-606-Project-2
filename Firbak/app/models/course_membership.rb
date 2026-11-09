#Renamed to Course since Class might conflict as and object

class CourseMembership < ApplicationRecord
  ROLES = %w[ instructor ta student].freeze

  belongs_to :course
  belongs_to :user

  validates :role, inclusion: { in: ROLES, message: "must be instructor, ta, or student"}
  validates :user_id, uniqueness: { scope: :course_id, message: "is already in this course"}

end
