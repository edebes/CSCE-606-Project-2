Feature: live feedback reaches the targeted student mid-session
    # Issue #7 - Acceptance test that feedback an instructor or TA sends
    # mid-session appears for the targeted student live

    As an instructor or TA
    So that I can help a specific student without interrupting the whole class
    I want live feedback I send mid-session to appear only for that student

Background: an active session with two students and a TA

  Given the following users exist:
  | id | name  | email           | password    | role       |
  | 1  | Anne  | anne@gmail.com  | password123 | instructor |
  | 2  | Theo  | theo@gmail.com  | password123 | TA         |
  | 3  | Alice | alice@gmail.com | password123 | student    |
  | 4  | Bob   | bob@gmail.com   | password123 | student    |

  Given the following question set exists:
  | id | title  | owner_id |
  | 1  | Week 5 | 1        |

  Given the following questions exist:
  | id | number | body           | question_set_id |
  | 1  | 1      | What is 3 * 2? | 1               |

  Given the following choices exist:
  | id | question_id | body | correct | feedback      |
  | 1  | 1           | 5    | false   | That is 3 + 2 |
  | 2  | 1           | 6    | true    |               |

  Given the following session exists:
  | id | question_set_id | host_id | code | status |
  | 1  | 1               | 1       | 1234 | active |

  Given the following participants exist:
  | session_id | user_id |
  | 1          | 2       |
  | 1          | 3       |
  | 1          | 4       |

Scenario: instructor sends live feedback to one student
  Given I log in as "anne@gmail.com"
  And   I am viewing the live session "1234"
  When  I send live feedback "Watch the operator — multiply, do not add" to student "Alice"
  And   I log out
  And   I log in as "alice@gmail.com"
  And   I am in the live session "1234"
  Then  I should see live feedback "Watch the operator — multiply, do not add"

Scenario: live feedback is not shown to other students
  Given I log in as "anne@gmail.com"
  And   I am viewing the live session "1234"
  When  I send live feedback "Watch the operator — multiply, do not add" to student "Alice"
  And   I log out
  And   I log in as "bob@gmail.com"
  And   I am in the live session "1234"
  Then  I should not see live feedback "Watch the operator — multiply, do not add"

Scenario: TA can send live feedback to a student
  Given I log in as "theo@gmail.com"
  And   I am viewing the live session "1234"
  When  I send live feedback "Try counting three groups of two" to student "Bob"
  And   I log out
  And   I log in as "bob@gmail.com"
  And   I am in the live session "1234"
  Then  I should see live feedback "Try counting three groups of two"

Scenario: student cannot send live feedback
  Given I log in as "alice@gmail.com"
  And   I am in the live session "1234"
  When  I try to send live feedback "Nope" to student "Bob"
  Then  I should see "You are not authorized to do that"

Scenario: cannot send live feedback after the session has ended
  Given the session "1234" has ended
  And   I log in as "anne@gmail.com"
  And   I am viewing the live session "1234"
  When  I try to send live feedback "Too late" to student "Alice"
  Then  I should see "Session has ended"
