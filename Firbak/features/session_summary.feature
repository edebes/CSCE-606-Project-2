Feature: instructor sees a summary when ending a session
    # Issue #2 - Acceptance test that an instructor ending a session sees a
    # summary of answers and the questions most commonly missed

    As an instructor
    So that I know which concepts to revisit before moving on
    I want to see how the class answered and which questions were missed most

Background: a live session on a two-question set

  Given the following users exist:
  | id | name  | email           | password    | role       |
  | 1  | Anne  | anne@gmail.com  | password123 | instructor |
  | 2  | Alice | alice@gmail.com | password123 | student    |
  | 3  | Bob   | bob@gmail.com   | password123 | student    |
  | 4  | Carol | carol@gmail.com | password123 | student    |

  Given the following question set exists:
  | id | title  | owner_id |
  | 1  | Week 5 | 1        |

  Given the following questions exist:
  | id | number | body           | question_set_id |
  | 1  | 1      | What is 3 * 2? | 1               |
  | 2  | 2      | What is 4 * 4? | 1               |

  Given the following choices exist:
  | id | question_id | body | correct | feedback                 |
  | 1  | 1           | 5    | false   | That is 3 + 2            |
  | 2  | 1           | 6    | true    |                          |
  | 3  | 1           | 8    | false   | Count the groups again   |
  | 4  | 2           | 8    | false   | That is 4 + 4            |
  | 5  | 2           | 16   | true    |                          |
  | 6  | 2           | 44   | false   | Multiply, do not join    |

  Given the following session exists:
  | id | question_set_id | host_id | code | status |
  | 1  | 1               | 1       | 1234 | active |

  Given I log in as "anne@gmail.com"

Scenario: summary shows how each question was answered
  Given the following responses exist:
  | session_id | user_id | question_id | choice_id |
  | 1          | 2       | 1           | 2         |
  | 1          | 3       | 1           | 1         |
  | 1          | 4       | 1           | 2         |
  | 1          | 2       | 2           | 5         |
  When I end the session "1234"
  Then I should see "Session summary"
  And  the summary should show:
  | question       | correct | answered |
  | What is 3 * 2? | 2       | 3        |
  | What is 4 * 4? | 1       | 1        |
  And  the summary should show choice "5" chosen 1 times for "What is 3 * 2?"
  And  the summary should show choice "6" chosen 2 times for "What is 3 * 2?"

Scenario: most commonly missed questions are listed first
  Given the following responses exist:
  | session_id | user_id | question_id | choice_id |
  | 1          | 2       | 1           | 2         |
  | 1          | 3       | 1           | 2         |
  | 1          | 2       | 2           | 4         |
  | 1          | 3       | 2           | 6         |
  When I end the session "1234"
  Then "What is 4 * 4?" should appear before "What is 3 * 2?" in the most missed list

Scenario: ending a session nobody answered
  When I end the session "1234"
  Then I should see "No answers were submitted in this session"

Scenario: a student cannot view the session summary
  Given the session "1234" has ended
  When I log out
  And  I log in as "alice@gmail.com"
  And  I visit the summary for session "1234"
  Then I should see "You are not authorized to do that"
