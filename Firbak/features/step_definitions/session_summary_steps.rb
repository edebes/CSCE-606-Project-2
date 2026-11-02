# Steps for features/session_summary.feature (issue #2).
#
# Setup steps for users, question sets, questions, choices and sessions are
# reused from feedbacks_steps.rb. The model is called Session to match that
# file; if the team renames it (e.g. GameSession), change it here too.
#
# What the app must provide:
#   - the session page has an "End session" button, which ends the session
#     and redirects to the summary page (heading "Session summary")
#   - route: summary_session_path(session)
#   - summary page: one element with class "question-summary" per question,
#     containing the question text, "<correct> of <answered> correct", and a
#     table with one row per choice: first cell the choice, then its count
#   - an element with id "most-missed" listing questions, most missed first

Given("the following responses exist:") do |table|
  table.hashes.each do |response|
    Response.create!(response)
  end
end

Given("the session {string} has ended") do |code|
  Session.find_by!(code: code).update!(status: "ended")
end

When("I end the session {string}") do |code|
  visit session_path(Session.find_by!(code: code))
  click_button "End session"
end

When("I visit the summary for session {string}") do |code|
  visit summary_session_path(Session.find_by!(code: code))
end

Then("the summary should show:") do |table|
  table.hashes.each do |row|
    within(".question-summary", text: row["question"]) do
      expect(page).to have_content("#{row['correct']} of #{row['answered']} correct")
    end
  end
end

Then("the summary should show choice {string} chosen {int} times for {string}") do |choice, count, question|
  within(".question-summary", text: question) do
    choice_row = find(:xpath, ".//tr[td[1][normalize-space()='#{choice}']]")
    expect(choice_row).to have_css("td", exact_text: count.to_s)
  end
end

Then("{string} should appear before {string} in the most missed list") do |first, second|
  list = find("#most-missed").text
  expect(list).to include(first, second)
  expect(list.index(first)).to be < list.index(second)
end
