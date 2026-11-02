Feature: instructor can end a live session
    # Issue #10 - Acceptance test that the instructor can end the session

    As an instructor
    So that I can wrap up the in-class activity when we are done
    I want to end an active session and stop further participation

Background: an active session with students joined

  Given the following users exist:
  | id | name  | email           | password    | role       |
  | 1  | Anne  | anne@gmail.com  | password123 | instructor |
  | 2  | Alice | alice@gmail.com | password123 | student    |
  | 3  | Bob   | bob@gmail.com   | password123 | student    |

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

  Given I log in as "anne@gmail.com"

Scenario: instructor ends an active session
  When I end the session "1234"
  Then I should see "Session ended"
  And  the session "1234" should have status "ended"

Scenario: students cannot submit answers after the session ends
  When I end the session "1234"
  And  I log out
  And  I log in as "alice@gmail.com"
  And  I am in the live session "1234"
  Then I should see "Session has ended"
  And  I should not be able to submit an answer

Scenario: a student cannot end the session
  When I log out
  And  I log in as "alice@gmail.com"
  And  I am in the live session "1234"
  When I try to end the session "1234"
  Then I should see "You are not authorized to do that"
  And  the session "1234" should have status "active"

Scenario: ending an already ended session is rejected
  Given the session "1234" has ended
  When I try to end the session "1234"
  Then I should see "Session has already ended"
