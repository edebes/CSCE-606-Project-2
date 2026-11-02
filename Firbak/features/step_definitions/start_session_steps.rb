# Steps for features/start_session.feature (issue #12).
#
# Setup steps (users, question sets, questions, choices), "I log in as" and
# "I should see {string}" are reused from feedbacks_steps.rb and
# authentication_steps.rb - not redefined, to avoid "Ambiguous step" errors.
#
# The model is called Session to match the other step files; if the team
# renames it (e.g. GameSession), change it here too.
#
# What the app must provide:
#   - the question sets page lists each set in its own table row with a
#     "Start session" button (a plain form button, so it works without JavaScript)
#   - route: launch_session_question_set_path(question_set), a POST that
#     creates the session (QuestionSetsController#launch_session in the design doc)
#   - on success, redirect to the session page showing "Session started" and
#     the join code

When("I start a session on the question set {string}") do |title|
  visit question_sets_path
  within("tr", text: title) { click_button "Start session" }
end

# Sends the request directly, the way someone could by crafting it by hand -
# used for sets the logged-in user shouldn't even see a button for.
When("I try to start a session on the question set {string}") do |title|
  question_set = QuestionSet.find_by!(title: title)
  page.driver.submit :post, launch_session_question_set_path(question_set), {}
end

Then("I should see the join code for {string}") do |title|
  session = Session.where(question_set: QuestionSet.find_by!(title: title)).order(:created_at).last
  expect(session).not_to be_nil
  expect(page).to have_content(session.code)
end

Then("a live session should exist for {string}") do |title|
  question_set = QuestionSet.find_by!(title: title)
  expect(Session.where(question_set: question_set, status: "active")).to exist
end

Then("no session should exist for {string}") do |title|
  question_set = QuestionSet.find_by!(title: title)
  expect(Session.where(question_set: question_set)).not_to exist
end

Then("the live sessions for {string} should have different join codes") do |title|
  codes = Session.where(question_set: QuestionSet.find_by!(title: title), status: "active").pluck(:code)
  expect(codes.size).to eq(2)
  expect(codes.uniq.size).to eq(2)
end
