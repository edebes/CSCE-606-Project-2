# Steps for features/live_feedback_mid_session.feature (issue #7).
#
# Setup steps for users, question sets, questions, choices and sessions are
# reused from feedbacks_steps.rb / session_summary_steps.rb. "I should see"
# and "I log in as" / "I log out" are also shared.
#
# What the app must provide:
#   - route: session_path(session) for the live session page (host and participant views)
#   - on the host/TA session page: a way to pick a student by name and a
#     "Live feedback" text field plus a "Send feedback" button
#   - POST /sessions/:id/feedback (or equivalent) creating a Feedback for
#     that student; only the targeted student sees it
#   - student session page: an element with class "live-feedback" that shows
#     the feedback content when it is delivered to them
#   - students cannot send live feedback; ended sessions reject new feedback
#     with "Session has ended"

Given("the following participants exist:") do |table|
  table.hashes.each do |row|
    session = Session.find(row["session_id"])
    user = User.find(row["user_id"])
    session.participants << user unless session.participants.include?(user)
  end
end

Given("I am viewing the live session {string}") do |code|
  visit session_path(Session.find_by!(code: code))
end

Given("I am in the live session {string}") do |code|
  visit session_path(Session.find_by!(code: code))
end

When("I send live feedback {string} to student {string}") do |message, student_name|
  select student_name, from: "Student"
  fill_in "Live feedback", with: message
  click_button "Send feedback"
end

When("I try to send live feedback {string} to student {string}") do |message, student_name|
  if page.has_select?("Student", wait: 0)
    select student_name, from: "Student"
    fill_in "Live feedback", with: message
    click_button "Send feedback"
  else
    session = Session.find_by!(code: "1234")
    student = User.find_by!(name: student_name)
    visit send_feedback_session_path(session, student_id: student.id, content: message)
  end
end

Then("I should see live feedback {string}") do |message|
  within(".live-feedback") do
    expect(page).to have_content(message)
  end
end

Then("I should not see live feedback {string}") do |message|
  if page.has_css?(".live-feedback", wait: 0)
    within(".live-feedback") do
      expect(page).not_to have_content(message)
    end
  else
    expect(page).not_to have_content(message)
  end
end
