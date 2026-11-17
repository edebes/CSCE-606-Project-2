Feature: students move through a session at their own pace
    # Issue #50

    As a student
    So that I can complete a session
    I want to be able to move through a question set in a session

Background:

  Given the following users exist:
  | id | name  | email           | password    | role       |
  | 1  | Anne  | anne@gmail.com  | password123 | instructor |
  | 2  | Alice | alice@gmail.com | password123 | student    |
  | 3  | Theo  | theo@gmail.com  | password123 | ta         |

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

Scenario: student sees the first question after joining
  Given I log in as "alice@gmail.com"
  And   I am in the live session "1234"
  Then  I should see "Question 1 of 2"
  And   I should see "What is 3 * 2?"

Scenario: a wrong answer keeps the student on the same question
  Given I log in as "alice@gmail.com"
  And   I am in the live session "1234"
  When  I answer with "5"
  Then  I should see "Question 1 of 2"

Scenario: a correct answer moves the student to the next question
  Given I log in as "alice@gmail.com"
  And   I am in the live session "1234"
  When  I answer with "6"
  Then  I should see "Question 2 of 2"
  And   I should see "What is 4 * 4?"

Scenario: answering every question correctly finishes the set
  Given I log in as "alice@gmail.com"
  And   I am in the live session "1234"
  When  I answer with "6"
  And   I answer with "16"
  Then  I should see "You have completed all questions in this session."
  And   I should not be able to submit an answer

Scenario: a student who leaves and rejoins keeps their place
  Given I log in as "alice@gmail.com"
  And   I am in the live session "1234"
  When  I answer with "6"
  And   I press "Leave session"
  Then  I should see "You have left the session."
  When  I join the session with code "1234"
  Then  I should see "Question 2 of 2"

Scenario: a TA can join and answer
  Given I log in as "theo@gmail.com"
  When  I join the session with code "1234"
  Then  I should see "Question 1 of 2"

Scenario: the host sees each participant's progress
  Given I log in as "alice@gmail.com"
  And   I am in the live session "1234"
  And   I answer with "6"
  And   I log out
  And   I log in as "anne@gmail.com"
  When  I am in the live session "1234"
  Then  I should see "Alice"
  And   I should see "Question 2"

Scenario: students are removed when the host ends the session
  Given I log in as "anne@gmail.com"
  And   I end the session "1234"
  And   I log out
  And   I log in as "alice@gmail.com"
  When  I am in the live session "1234"
  Then  I should see "Session has ended"
  And   I should not be able to submit an answer

Scenario: students are removed when the host leaves the session
  Given I log in as "anne@gmail.com"
  And   I am in the live session "1234"
  And   I press "Leave session"
  Then  the session "1234" should have status "ended"

Scenario: someone who has not joined cannot see the questions
  Given I log in as "theo@gmail.com"
  When  I am in the live session "1234"
  Then  I should see "You are not a participant in this session."
  And   I should not see "What is 3 * 2?"

Scenario: students are removed when the host logs out
  Given I log in as "anne@gmail.com"
  And   I log out
  Then  the session "1234" should have status "ended"