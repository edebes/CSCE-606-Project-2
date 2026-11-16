# Steps for features/move_through_sessions.feature (issue 50)
#
# Shared steps reused (do not redefine):
#   - "I am in the live session"
#     from live_feedback_steps.rb
#   - "I join the session with code {string}"
#     from join_session_steps.rb
#   - "I end the session {string}"
#     from session_summary_steps.rb
#   - "I should not be able to submit an answer" and "the session {string} should have status {string}"
#     from end_session_steps.rb
#   - "I should see {string}" and "I should not see {string}"
#     from feedbacks_steps.rb
#
# What the app must provide:
#   - session page must show current question description and 
#     choices for each user
#   - session page must show participant table for host
#   - session page has a "Leave session" button
#   - session page has a "End session" button for host
#   - host can end the session by logging out

When("I press {string}") do |label|
  click_button label
end