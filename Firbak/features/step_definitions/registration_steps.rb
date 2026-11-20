# Steps for features/student_registration.feature (issue #62).
# The sign-up page has fields labelled "Name", "Email", "Password" and
# "Confirm password", and a "Create account" button.

Given("I am on the login page") do
  visit login_path
end

Given("I am on the sign up page") do
  visit signup_path
end

When("I follow {string}") do |link|
  click_link link
end

When("I sign up as {string} with email {string}, password {string} and confirmation {string}") do |name, email, password, confirmation|
  visit signup_path unless page.current_path == signup_path
  fill_in "Name", with: name
  fill_in "Email", with: email
  fill_in "Password", with: password
  fill_in "Confirm password", with: confirmation
  click_button "Create account"
end