Feature: instructor starts a session on a question set
    # Issue #12 - Acceptance test that an instructor can start a session on a question set

    As an instructor
    So that my students can work through a question set together in class
    I want to start a live session on one of my question sets and get a code to share

Background: two instructors, a student, and three question sets

  Given the following users exist:
  | id | name | email          | password    | role       |
  | 1  | Anne | anne@gmail.com | password123 | instructor |
  | 2  | Ben  | ben@gmail.com  | password123 | instructor |
  | 3  | John | john@gmail.com | password123 | student    |

  Given the following question set exists:
  | id | title          | owner_id |
  | 1  | Week 5         | 1        |
  | 2  | Physics Review | 2        |
  | 3  | Empty Set      | 1        |

  Given the following questions exist:
  | id | number | body              | question_set_id |
  | 1  | 1      | What is 3 * 2?    | 1               |
  | 2  | 1      | What is a newton? | 2               |

  Given the following choices exist:
  | id | question_id | body        | correct | feedback      |
  | 1  | 1           | 5           | false   | That is 3 + 2 |
  | 2  | 1           | 6           | true    |               |
  | 3  | 2           | A force     | true    |               |
  | 4  | 2           | An energy   | false   | Check units   |

Scenario: instructor starts a session on their own question set
  Given I log in as "anne@gmail.com"
  When  I start a session on the question set "Week 5"
  Then  I should see "Session started"
  And   I should see the join code for "Week 5"
  And   a live session should exist for "Week 5"

Scenario: each new session gets its own join code
  Given I log in as "anne@gmail.com"
  When  I start a session on the question set "Week 5"
  And   I start a session on the question set "Week 5"
  Then  the live sessions for "Week 5" should have different join codes

Scenario: cannot start a session on a question set with no questions
  Given I log in as "anne@gmail.com"
  When  I start a session on the question set "Empty Set"
  Then  I should see "Add at least one question before starting a session"
  And   no session should exist for "Empty Set"

Scenario: an instructor cannot start a session on another instructor's set
  Given I log in as "anne@gmail.com"
  When  I try to start a session on the question set "Physics Review"
  Then  I should see "You are not authorized to do that"
  And   no session should exist for "Physics Review"

Scenario: a student cannot start a session
  Given I log in as "john@gmail.com"
  When  I try to start a session on the question set "Week 5"
  Then  I should see "You are not authorized to do that"
  And   no session should exist for "Week 5"
