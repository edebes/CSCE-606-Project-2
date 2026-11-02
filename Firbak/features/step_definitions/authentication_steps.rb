# Shared login/logout steps, used by any feature that needs a signed-in user.
#
# What the app must provide for these to pass:
#   - a login page at /login with fields labelled "Email" and "Password"
#     and a "Log in" button
#   - a "Log out" button in the layout when someone is signed in
#
# Every user created in a feature's "the following users exist:" table uses
# this password, so the step doesn't need it spelled out each time.
TEST_PASSWORD = "password123"

When("I log in as {string}") do |email|
  visit "/login"
  fill_in "Email", with: email
  fill_in "Password", with: TEST_PASSWORD
  click_button "Log in"
end

When("I log out") do
  click_button "Log out"
end
