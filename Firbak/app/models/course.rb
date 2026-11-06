#Renamed to Course since Class might conflict as and object

class Course < ApplicationRecord
    has_many :course_memberships, dependent: :destroy
    has_many :members, through: :course_memberships, source: :user

    has_many :instructors, -> {where(course_memberships: {role: "instructor"})},
                through: :course_memberships, source: :user
    has_many :tas, -> { where(course_memberships: { role: "ta"})},
                through: :course_memberships, source: :user
    has_many :students, -> { where(course_memberships: { role: "student"})},
                through: :course_memberships, source: :user
    
    validates :name, presence: true


    def add_member(user, role)
        membership = course_memberships.find_or_initialize_by(user: user)
        membership.role = role.to_s.downcase
        membership.save
    end

    def remove_member(user)
        course_memberships.where(user: user).destroy_all.any?
    end

    def enrolled_students
        students
    end

    def member?(user)
        course_memberships.exists?(user: user)
    end

    def role_of(user)
        course_memberships.find_by(user: user)&.role
    end

end
