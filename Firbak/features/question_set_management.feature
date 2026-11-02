Feature: instructor manages question sets
    # Issue #1 - Acceptance test that an instructor can make persistent changes
    # (create, edit, and delete a question set)

    As an instructor
    So that I can reuse worked examples across lectures
    I want to create, edit, and delete question sets that stay saved to my account

Background: two instructors and a student, each instructor owns one set

  Given the following users exist:
  | id | name | email          | password    | role       |
  | 1  | Anne | anne@gmail.com | password123 | instructor |
  | 2  | Ben  | ben@gmail.com  | password123 | instructor |
  | 3  | John | john@gmail.com | password123 | student    |

  Given the following question set exists:
  | id | title          | owner_id |
  | 1  | Howdy          | 1        |
  | 2  | Physics Review | 2        |

  Given I log in as "anne@gmail.com"

Scenario: create a question set with a question and answer choices
  When I create a question set "Week 5" with the question "What is 3 * 2?" and choices:
  | body | correct | feedback                          |
  | 5    | false   | Check the operator: that is 3 + 2 |
  | 6    | true    |                                   |
  | 8    | false   | Count again: three groups of two  |
  Then I should see "Question set created"
  And  the question set "Week 5" should be listed

Scenario: edit a question set
  When I rename the question set "Howdy" to "Week 5 Review"
  Then I should see "Question set updated"
  And  the question set "Week 5 Review" should be listed
  And  the question set "Howdy" should not be listed

Scenario: changes are still there after logging out and back in
  When I rename the question set "Howdy" to "Week 5 Review"
  And  I log out
  And  I log in as "anne@gmail.com"
  Then the question set "Week 5 Review" should be listed

Scenario: delete a question set
  When I delete the question set "Howdy"
  Then I should see "Question set deleted"
  And  the question set "Howdy" should not be listed

Scenario: cannot save a question with no correct answer
  When I create a question set "Week 6" with the question "What is 3 * 2?" and choices:
  | body | correct | feedback |
  | 5    | false   | Nope     |
  | 6    | false   |          |
  Then I should see "Each question must have exactly one correct answer"
  And  no question set titled "Week 6" should exist

Scenario: cannot save a question set without a title
  When I create a question set "" with the question "What is 3 * 2?" and choices:
  | body | correct | feedback |
  | 5    | false   | Nope     |
  | 6    | true    |          |
  Then I should see "Title can't be blank"

Scenario: an instructor cannot see or edit another instructor's set
  Then the question set "Physics Review" should not be listed
  When I try to edit the question set "Physics Review"
  Then I should see "You are not authorized to do that"

Scenario: a student cannot create question sets
  When I log out
  And  I log in as "john@gmail.com"
  And  I go to the new question set page
  Then I should see "You are not authorized to do that"
