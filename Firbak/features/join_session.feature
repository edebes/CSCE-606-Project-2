Feature: students and TAs join a session with a code
    # Issue #11 - Acceptance test that students/TAs can join with the right
    # code and get a clear error on a wrong one

    As a student or TA
    So that I can take part in the in-class session
    I want to join with the session code and see a clear error if it is wrong

Background: an active session ready to join

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

Scenario: student joins with the correct code
  Given I log in as "alice@gmail.com"
  When  I join the session with code "1234"
  Then  I should see "Joined session"
  And   I should be in the live session "1234"
  And   "Alice" should be a participant of session "1234"

Scenario: TA joins with the correct code
  Given I log in as "theo@gmail.com"
  When  I join the session with code "1234"
  Then  I should see "Joined session"
  And   I should be in the live session "1234"
  And   "Theo" should be a participant of session "1234"

Scenario: student gets a clear error on a wrong code
  Given I log in as "alice@gmail.com"
  When  I join the session with code "9999"
  Then  I should see "Invalid session code"
  And   I should not be in a live session
  And   "Alice" should not be a participant of session "1234"

Scenario: TA gets a clear error on a wrong code
  Given I log in as "theo@gmail.com"
  When  I join the session with code "0000"
  Then  I should see "Invalid session code"
  And   I should not be in a live session

Scenario: cannot join a session that has ended
  Given the session "1234" has ended
  And   I log in as "alice@gmail.com"
  When  I join the session with code "1234"
  Then  I should see "Session has ended"
  And   "Alice" should not be a participant of session "1234"

Scenario: blank code shows a clear error
  Given I log in as "bob@gmail.com"
  When  I join the session with code ""
  Then  I should see "Invalid session code"
