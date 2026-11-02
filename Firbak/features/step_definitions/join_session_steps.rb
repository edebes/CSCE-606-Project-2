# Steps for features/join_session.feature (issue #11).
#
# Shared steps reused (do not redefine):
#   - setup tables from feedbacks_steps.rb
#   - "I log in as" from authentication_steps.rb
#   - "the session {string} has ended" from session_summary_steps.rb
#   - "I should see {string}" from feedbacks_steps.rb
#
# What the app must provide:
#   - join page at join_session_path (or /sessions/join) with a
#     "Session code" field and a "Join" button
#   - correct code: adds the user as a participant, flashes
#     "Joined session", redirects to session_path
#   - wrong or blank code: stays on join page, flashes
#     "Invalid session code"
#   - ended session with a valid code: flashes "Session has ended"

When("I join the session with code {string}") do |code|
  visit join_session_path
  fill_in "Session code", with: code
  click_button "Join"
end

Then("I should be in the live session {string}") do |code|
  session = Session.find_by!(code: code)
  expect(page).to have_current_path(session_path(session), ignore_query: true)
end

Then("I should not be in a live session") do
  expect(page).to have_current_path(join_session_path, ignore_query: true)
end

Then("{string} should be a participant of session {string}") do |name, code|
  session = Session.find_by!(code: code)
  user = User.find_by!(name: name)
  expect(session.participants).to include(user)
end

Then("{string} should not be a participant of session {string}") do |name, code|
  session = Session.find_by!(code: code)
  user = User.find_by!(name: name)
  expect(session.participants).not_to include(user)
end
