require "rails_helper"

#Spec for Course

RSpec.describe Course, type: :model do
  let(:course)     { Course.create!(name: "CSCE 606") }
  let(:instructor) { User.create!(user_id: 1001, name: "Anne",  email: "anne@tamu.edu",  role: "instructor") }
  let(:ta)         { User.create!(user_id: 1002, name: "Tara",  email: "tara@tamu.edu",  role: "ta") }
  let(:student)    { User.create!(user_id: 1003, name: "John",  email: "john@tamu.edu",  role: "student") }

  it "requires a name" do
    expect(Course.new(name: "")).not_to be_valid
  end

  describe "#add_member" do
    it "adds users with their role in the course" do
      course.add_member(instructor, :instructor)
      course.add_member(ta, "TA")
      course.add_member(student, :student)

      expect(course.instructors).to contain_exactly(instructor)
      expect(course.tas).to contain_exactly(ta)
      expect(course.students).to contain_exactly(student)
    end

    it "rejects an unknown role" do
      expect(course.add_member(student, :admin)).to be false
      expect(course.member?(student)).to be false
    end

    it "changes the role instead of adding the user twice" do
      course.add_member(student, :student)
      course.add_member(student, :ta)

      expect(course.members.count).to eq(1)
      expect(course.role_of(student)).to eq("ta")
    end
  end

  describe "#remove_member" do
    it "removes a member" do
      course.add_member(student, :student)
      expect(course.remove_member(student)).to be true
      expect(course.member?(student)).to be false
    end

    it "returns false for someone who isn't a member" do
      expect(course.remove_member(student)).to be false
    end
  end

  it "lists only students as enrolled students" do
    course.add_member(instructor, :instructor)
    course.add_member(student, :student)
    expect(course.enrolled_students).to contain_exactly(student)
  end

  it "shows a user's courses" do
    course.add_member(student, :student)
    expect(student.courses).to include(course)
  end

  it "removes memberships when the course is deleted" do
    course.add_member(student, :student)
    course.destroy
    expect(CourseMembership.count).to eq(0)
  end
end