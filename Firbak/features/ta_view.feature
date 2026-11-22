Feature: TAs monitor a live session
    # Issue #30 - TAs (and instructors who are not the host) join with the
    # session code and see the host's monitoring view instead of the questions.

    As a TA
    So that I can help provide live-feedback
    I want to be able to join an in-class session as a TA role

Background: an active session with a student already in it

  Given the following users exist:
  | id | name  | email           | password    | role       |
  | 1  | Anne  | anne@gmail.com  | password123 | instructor |
  | 2  | Alice | alice@gmail.com | password123 | student    |
  | 3  | Theo  | theo@gmail.com  | password123 | ta         |
  | 4  | Ian   | ian@gmail.com   | password123 | instructor |

  Given the following question set exists:
  | id | title  | owner_id |
  | 1  | Week 5 | 1        |

  Given the following questions exist:
  | id | number | body           | question_set_id |
  | 1  | 1      | What is 3 * 2? | 1               |
  | 2  | 2      | What is 4 * 4? | 1               |

  Given the following choices exist:
  | id | question_id | body | correct | feedback |
  | 1  | 1           | 5    | false   |          |
  | 2  | 1           | 6    | true    |          |
  | 3  | 2           | 8    | false   |          |
  | 4  | 2           | 16   | true    |          |

  Given the following session exists:
  | id | question_set_id | host_id | code | status |
  | 1  | 1               | 1       | 1234 | active |

  Given the following participants exist:
  | session_id | user_id |
  | 1          | 2       |

Scenario: a TA joins and sees the monitoring view
  Given I log in as "theo@gmail.com"
  When  I join the session with code "1234"
  Then  I should see "Joined session"
  And   I should be in the live session "1234"
  And   I should see "Struggling"
  And   the participant table should include "Alice"
  And   the participant table should not include "Theo"
  And   I should not see "What is 3 * 2?"
  And   I should not be able to submit an answer

Scenario: a TA can leave but cannot end the session
  Given I log in as "theo@gmail.com"
  When  I join the session with code "1234"
  Then  I should see a "Leave session" button
  And   I should not see a "End session" button

Scenario: a TA sees a student's progress
  Given I log in as "alice@gmail.com"
  And   I am in the live session "1234"
  And   I answer with "6"
  And   I log out
  And   I log in as "theo@gmail.com"
  When  I join the session with code "1234"
  Then  the participant table should include "Question 2"

Scenario: a TA sees when a student is struggling
  Given I log in as "alice@gmail.com"
  And   I am in the live session "1234"
  And   I answer with "5"
  And   I log out
  And   I log in as "theo@gmail.com"
  When  I join the session with code "1234"
  Then  the participant table should include "Yes"

Scenario: a TA leaving does not end the session
  Given I log in as "theo@gmail.com"
  And   I join the session with code "1234"
  When  I press "Leave session"
  Then  I should see "You have left the session."
  And   I should be on the join session page
  And   the session "1234" should have status "active"

Scenario: a TA cannot end the session directly
  Given I log in as "theo@gmail.com"
  And   I join the session with code "1234"
  When  I try to end the session "1234"
  Then  I should see "You are not authorized to do that."
  And   the session "1234" should have status "active"

Scenario: a TA who has not joined cannot see the session
  Given I log in as "theo@gmail.com"
  When  I am in the live session "1234"
  Then  I should see "You are not a participant in this session."
  And   the participant table should not be shown

Scenario: a TA does not get the summary link after the session ends
  Given I log in as "theo@gmail.com"
  And   I join the session with code "1234"
  And   the session "1234" has ended
  When  I am in the live session "1234"
  Then  I should see "Session has ended."
  And   I should not see a "View session summary" link

Scenario: the host gets the summary link after the session ends
  Given I log in as "anne@gmail.com"
  And   the session "1234" has ended
  When  I am in the live session "1234"
  Then  I should see a "View session summary" link

Scenario: TAs are not counted as participants in the summary
  Given I log in as "alice@gmail.com"
  And   I am in the live session "1234"
  And   I answer with "6"
  And   I log out
  And   I log in as "theo@gmail.com"
  And   I join the session with code "1234"
  And   I log out
  And   I log in as "anne@gmail.com"
  When  I end the session "1234"
  Then  I should see "Session summary"
  And   I should see "1 participants"

Scenario: an instructor who joins another instructor's session gets the monitoring view
  Given I log in as "ian@gmail.com"
  When  I join the session with code "1234"
  Then  the participant table should include "Alice"
  And   the participant table should not include "Ian"
  And   I should see a "Leave session" button
  And   I should not see a "End session" button

# Navigation

Scenario: an instructor lands on their question sets after logging in
  Given I log in as "anne@gmail.com"
  Then  I should be on the question sets page
  And   I should see a "Question sets" link

Scenario: a TA lands on the join page after logging in
  Given I log in as "theo@gmail.com"
  Then  I should be on the join session page
  And   I should not see a "Question sets" link

Scenario: a student lands on the join page after logging in
  Given I log in as "alice@gmail.com"
  Then  I should be on the join session page
  And   I should not see a "Question sets" link

Scenario: the home page is the join page
  Given I log in as "theo@gmail.com"
  When  I visit the home page
  Then  I should see the join session form

Scenario: the session page does not link back to question sets
  Given I log in as "theo@gmail.com"
  When  I join the session with code "1234"
  Then  I should not see a "Back to question sets" link