# Steps for features/student_receiving_feedback.feature (issue #28).
# The student's session page shows the current question with one radio button
# per choice (labelled with the choice text) and a "Submit" button.

When("I answer with {string}") do |choice|
  choose choice
  click_button "Submit"
end