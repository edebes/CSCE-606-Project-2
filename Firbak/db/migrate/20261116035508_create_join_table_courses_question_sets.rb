class CreateJoinTableCoursesQuestionSets < ActiveRecord::Migration[8.1]
  def change
    create_join_table :courses, :question_sets do |t|
      t.index [:course_id, :question_set_id]
      t.index [:question_set_id, :course_id]
    end
  end
end
