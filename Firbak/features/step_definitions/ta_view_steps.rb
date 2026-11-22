# Steps for features/ta_view.feature (issue #30).
#
# Shared steps reused (do not redefine):
#   - setup tables and "I should see {string}" / "I should not see {string}"
#     from feedbacks_steps.rb
#   - "the following participants exist:" and "I am in the live session {string}"
#     from live_feedback_steps.rb
#   - "I log in as {string}" and "I log out" from authentication_steps.rb
#   - "I join the session with code {string}" and
#     "I should be in the live session {string}" from join_session_steps.rb
#   - "I try to end the session {string}", "I should not be able to submit an answer"
#     and "the session {string} should have status {string}" from end_session_steps.rb
#   - "the session {string} has ended" and "I end the session {string}"
#     from session_summary_steps.rb
#   - "I answer with {string}" from answer_steps.rb
#   - "I should see a {string} button" from resubmission_steps.rb
#   - "I press {string}" from move_through_session.rb
#
# What the app must provide:
#   - the host view shows a table with id "participants" that lists students only

When("I visit the home page") do
  visit root_path
end

Then("I should be on the join session page") do
  expect(page).to have_current_path(join_session_path, ignore_query: true)
end

Then("I should see the join session form") do
  expect(page).to have_field("Session code")
  expect(page).to have_button("Join")
end

Then("I should be on the question sets page") do
  expect(page).to have_current_path(question_sets_path, ignore_query: true)
end

Then("I should see a {string} link") do |label|
  expect(page).to have_link(label)
end

Then("I should not see a {string} link") do |label|
  expect(page).to have_no_link(label)
end

Then("I should not see a {string} button") do |label|
  expect(page).to have_no_button(label)
end

Then("the participant table should include {string}") do |text|
  within("#participants") { expect(page).to have_content(text) }
end

Then("the participant table should not include {string}") do |text|
  within("#participants") { expect(page).not_to have_content(text) }
end

Then("the participant table should not be shown") do
  expect(page).to have_no_css("#participants")
end