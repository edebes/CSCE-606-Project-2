class User < ActiveRecord::Base
    has_many :course_memberships, dependent: :destroy
    has_many :courses, through: :course_memberships
end