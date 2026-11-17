Feature: students see the instructor's pre-programmed feedback on wrong answers
    # Issue #28 - pre-program feedback for common wrong answers

    As an instructor
    So that I can provide instant feedback to each of my students
    I want students who pick a common wrong answer to see the feedback I wrote for it

Background: a live session with two students in it

  Given the following users exist:
  | id | name | email          | password    | role       |
  | 1  | Anne | anne@gmail.com | password123 | instructor |
  | 2  | John | john@gmail.com | password123 | student    |
  | 3  | Lisa | lisa@gmail.com | password123 | student    |

  Given the following question set exists:
  | id | title  | owner_id |
  | 1  | Week 5 | 1        |

  Given the following questions exist:
  | id | number | body           | question_set_id |
  | 1  | 1      | What is 3 * 2? | 1               |
  | 2  | 2      | What is 4 * 4? | 1               |

  Given the following choices exist:
  | id | question_id | body | correct | feedback                 |
  | 1  | 1           | 5    | false   | That is 3 + 2, not 3 * 2 |
  | 2  | 1           | 6    | true    |                          |
  | 3  | 1           | 8    | false   |                          |
  | 4  | 2           | 16   | true    |                          |
  | 5  | 2           | 8    | false   | That is 4 + 4, not 4 * 4 |

  Given the following session exists:
  | id | question_set_id | host_id | code | status |
  | 1  | 1               | 1       | 1234 | active |

  Given the following participants exist:
  | session_id | user_id |
  | 1          | 2       |
  | 1          | 3       |

Scenario: a wrong answer shows the feedback written for that choice
  Given I log in as "john@gmail.com"
  And   I am in the live session "1234"
  When  I answer with "5"
  Then  I should see "Not quite."
  And   I should see "That is 3 + 2, not 3 * 2"
  And   I should see "What is 3 * 2?"

Scenario: the feedback is still there after refreshing the page
  Given I log in as "john@gmail.com"
  And   I am in the live session "1234"
  When  I answer with "5"
  And   I am in the live session "1234"
  Then  I should see "That is 3 + 2, not 3 * 2"

Scenario: a correct answer shows no corrective feedback and moves on
  Given I log in as "john@gmail.com"
  And   I am in the live session "1234"
  When  I answer with "6"
  Then  I should see "Correct!"
  And   I should not see "That is 3 + 2, not 3 * 2"
  And   I should see "What is 4 * 4?"

Scenario: a wrong answer with no pre-programmed feedback still says it is wrong
  Given I log in as "john@gmail.com"
  And   I am in the live session "1234"
  When  I answer with "8"
  Then  I should see "Not quite."
  And   I should not see "That is 3 + 2, not 3 * 2"

Scenario: feedback is only shown to the student who answered
  Given I log in as "john@gmail.com"
  And   I am in the live session "1234"
  When  I answer with "5"
  And   I log out
  And   I log in as "lisa@gmail.com"
  And   I am in the live session "1234"
  Then  I should not see "That is 3 + 2, not 3 * 2"