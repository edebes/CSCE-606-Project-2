Feature: new users register for a student account
    # Issue #62

    As a new user
    So that I can have my own account
    I want to be able to register for a student account

Background: someone already has an account

  Given the following users exist:
  | id | name | email          | password    | role       |
  | 1  | Anne | anne@gmail.com | password123 | instructor |

Scenario: register and start as a logged-in student
  Given I am on the login page
  When  I follow "Sign up"
  And   I sign up as "Kim Lee" with email "kim@gmail.com", password "password123" and confirmation "password123"
  Then  I should see "Welcome, Kim Lee! Your student account is ready."
  And   I should see "Kim Lee (student)"

Scenario: log in later with the new account, using any capitalization of the email
  Given I am on the sign up page
  When  I sign up as "Kim Lee" with email "Kim@Gmail.com", password "password123" and confirmation "password123"
  And   I log out
  And   I log in as "kim@gmail.com"
  Then  I should see "Kim Lee (student)"

Scenario: an email that is already registered is rejected
  Given I am on the sign up page
  When  I sign up as "Another Anne" with email "ANNE@gmail.com", password "password123" and confirmation "password123"
  Then  I should see "Email has already been taken"

Scenario: passwords that don't match are rejected
  Given I am on the sign up page
  When  I sign up as "Kim Lee" with email "kim@gmail.com", password "password123" and confirmation "password124"
  Then  I should see "Password confirmation doesn't match Password"

Scenario: a short password is rejected
  Given I am on the sign up page
  When  I sign up as "Kim Lee" with email "kim@gmail.com", password "short" and confirmation "short"
  Then  I should see "Password is too short (minimum is 8 characters)"

Scenario: a missing name is rejected
  Given I am on the sign up page
  When  I sign up as "" with email "kim@gmail.com", password "password123" and confirmation "password123"
  Then  I should see "Name can't be blank"