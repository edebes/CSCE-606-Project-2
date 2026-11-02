Feature: students receive feedback on incorrect answers

    As an instructor
    So that I can provide instant feedback to each of my students
    I want to be able to pre-program feedback for common wrong answers

Background: session is running

  Given the following session exists:
  | id | question_set_id | host | code | participants | status | responses | summary |
  | 12 | 2               | Anne | 1234 | [John, Lisa] | active | []        | []      |

  Given the following question set exists:
  | id | title | owner | questions | shared_with |
  | 2  | Howdy | Anne  | [1, 2]    | []          |

  Given the following questions exist:
  | id | number | body       | choices      | topics | question_sets |
  | 1  | 1      | Which one? | [1, 2, 3, 4] | []     | 2             |
  | 2  | 2      | Again?     | [5, 6]       | []     | 2             |

  Given the following choices exist:
  | id | body | correct | feedback  |
  | 1  | a    | false   | Nope      |
  | 2  | b    | false   | Wrong     |
  | 3  | c    | true    |           |
  | 4  | d    | false   | Try again |
  | 1  | Yes  | false   | Why?      |
  | 1  | No   | true    |           |

  Given the following users exist:
  | id | name | email          | role       | progression |
  | 1  | Anne | anne@gmail.com | instructor |             |
  | 2  | John | john@gmail.com | student    |             |
  | 3  | Lisa | lisa@gmail.com | student    |             |

Scenario: student gets feedback after wrong answer
  Given I am in session "2"
  And   I am on question "1"
  And   I am user "John"
  When  I select choice "2"
  Then  I should see "Wrong"
  And   I should not see "Nope"

Scenario: student should not get feedback after selecting correct answer
  Given I am in session "2"
  And   I am on question "1"
  And   I am user "Lisa"
  When  I select choice "2"
  Then  I should not see "Why?"
