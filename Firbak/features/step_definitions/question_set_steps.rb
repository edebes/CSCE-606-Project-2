# Steps for features/question_set_management.feature (issue #1).
#
# Setup steps ("the following users exist:", "the following question set
# exists:") and "I should see {string}" live in feedbacks_steps.rb - reused,
# not redefined, to avoid "Ambiguous step" errors.
#
# What the question set form (new/edit) must provide:
#   "Title"                        - text field for the set's title
#   "Question"                     - text field for the first question's body
#   "Choice 1" .. "Choice 4"       - text fields for each choice
#   "Feedback for choice 1" .. "4" - feedback shown when that wrong choice is picked
#   "Choice 1 is correct" .. "4"   - checkbox marking the correct choice
#   "Save question set"            - submit button
# The index page lists each set in its own table row with a "Delete" button.

When("I create a question set {string} with the question {string} and choices:") do |title, question, table|
  visit new_question_set_path
  fill_in "Title", with: title
  fill_in "Question", with: question
  table.hashes.each.with_index(1) do |row, n|
    fill_in "Choice #{n}", with: row["body"]
    fill_in "Feedback for choice #{n}", with: row["feedback"].to_s
    check "Choice #{n} is correct" if row["correct"] == "true"
  end
  click_button "Save question set"
end

When("I rename the question set {string} to {string}") do |old_title, new_title|
  visit edit_question_set_path(QuestionSet.find_by!(title: old_title))
  fill_in "Title", with: new_title
  click_button "Save question set"
end

When("I delete the question set {string}") do |title|
  visit question_sets_path
  within("tr", text: title) { click_button "Delete" }
end

When("I try to edit the question set {string}") do |title|
  visit edit_question_set_path(QuestionSet.find_by!(title: title))
end

When("I go to the new question set page") do
  visit new_question_set_path
end

Then("the question set {string} should be listed") do |title|
  visit question_sets_path
  expect(page).to have_content(title)
end

Then("the question set {string} should not be listed") do |title|
  visit question_sets_path
  expect(page).not_to have_content(title)
end

Then("no question set titled {string} should exist") do |title|
  expect(QuestionSet.find_by(title: title)).to be_nil
end
