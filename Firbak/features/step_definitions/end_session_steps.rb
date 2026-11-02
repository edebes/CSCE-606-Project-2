# Steps for features/end_session.feature (issue #10).
#
# Shared steps reused (do not redefine):
#   - "the following users/question set/questions/choices/session exist"
#     from feedbacks_steps.rb
#   - "the following participants exist" and "I am in the live session"
#     from live_feedback_steps.rb
#   - "I log in as" / "I log out" from authentication_steps.rb
#   - "I end the session {string}" and "the session {string} has ended"
#     from session_summary_steps.rb
#   - "I should see {string}" from feedbacks_steps.rb
#
# What the app must provide:
#   - session page has an "End session" button (instructor only)
#   - ending sets status to "ended" and shows "Session ended"
#   - students on an ended session see "Session has ended" and have no
#     Submit button
#   - students cannot end a session; already-ended sessions show
#     "Session has already ended"

When("I try to end the session {string}") do |code|
  session = Session.find_by!(code: code)
  visit session_path(session)
  if page.has_button?("End session", wait: 0)
    click_button "End session"
  else
    page.driver.submit :post, end_session_path(session), {}
  end
end

Then("the session {string} should have status {string}") do |code, status|
  expect(Session.find_by!(code: code).reload.status).to eq(status)
end

Then("I should not be able to submit an answer") do
  expect(page).to have_no_button("Submit")
end
