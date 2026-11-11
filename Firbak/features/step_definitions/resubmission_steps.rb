Given "a question {string} with an incorrect choice {string} and feedback {string}" do |body, choice_body, feedback|
  @question = create(:question, body: body)
  @wrong_choice = create(:choice, question: @question, body: choice_body, correct: false, feedback: feedback)
end

Given "the question has a correct choice {string}" do |choice_body|
  @correct_choice = create(:choice, question: @question, body: choice_body, correct: true)
end

Given "an instructor has launched a session for the question set" do
  instructor = create(:user, role: :instructor)
  question_set = create(:question_set, owner: instructor, questions: [ @question ])
  @session = question_set.launch_session
end

Given "I am signed in as a student" do
  @student = create(:user, role: :student)
  sign_in @student
end

Given "I haved joined the session with the correct code" do
  visit join_session_path
  fill_in "Session code", with: @session.code
  click_button "Join"
end

When "I select the choice {string} and submit my answer" do |choice_body|
  choose choice_body
  click_button "Submit"
end

When "I resubmit and select the choice {string}" do |choice_body|
  click_button "Resubmit"
  choose choice_body
  click_button "Submit"
end

When "I resubmit and select the choice {string} again" do |choice_body|
  click_button "Resubmit"
  choose choice_body
  click_button "Submit"
end

Then "I should expect to see the feedback {string}" do |text|
  expect(page).to have_content(text)
end

Then "I should expect to see the feedback {string} again" do |text|
  expect(page).to have_content(text)
end

Then "I should see a {string} button" do |label|
  expect(page).to have_button(label)
end

Then "I should still see a {string} button" do |label|
  expect(page).to have_button(label)
end

Then "I shuold not see a {string} button" do |label|
  expect(page).to have_no_button(label)
end

# "I should see {string}" is defined in feedbacks_steps.rb — do not redefine.
