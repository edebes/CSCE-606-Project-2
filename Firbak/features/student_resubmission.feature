Feature: Resubmitting an answer after feedback
  As a student, so that I can correct my mistakes in the same sesssion,
  I want to be able to resubmit my answer after receiving feedback on a wrong one.

  Background:  
    Given a question "2 + 2 = ?" with an incorrect choice f "3" and feedback "Check your addition."
    And the question has a correct choice of "4"
    And an instructor has launched a session for the question set
    And I am signed in as a student

  Scenario: Student resubmits after an incorrect answer and gets it right
    Given I have joined the session with the correct code
    When I select choice "3" and submit my answer
    Then I should see the feedback "Check your addition."
    And I should see a "Resubmit" button
    When I resubmit and select the choice "4"
    Then I should see "Correct!"
    And I should not see a "Resubmit" button
  
  Scenario: Student can resubmit more than once after repeated wrong answers
    Given I have joined the session with the correct code
    When I select the choice "3" and submit my answer
    Then I suold see a "Resubmit" button
    When I resubmit and select the choice "3" again
    Then I should see the feedback "Check your addition." again
    And I should still see a "Resubmit" button
  
  Scenario: Resubmit button does not appear after a correct first answer
    Given I have joined the session with the correct code
    When I select the choice "4" and submit my answer
    Then I shuold see "Correct!"
    And I should not see a "Resubmit" button

  Scenario: Resubmit button is unavailable after the session ends
    Given I have joined the session with the correct code
    And I select the choice "3" and submit my answer
    And I should see a "Resubmit" button
    When the instructor ends the session
    Then I should not see a "Resubmit" button
  
  Scenario: Resubmit button does not appear if resubmission has not been enabled
    Given I have joined the session with the correct code
    And resubmission has not been allowed for this question
    When I select the choice "3" and submit my answer
    Then I should see the feedback "Check your addition."
    And I should not see a "Resubmit" button

  Scenario: Resubmit button only appears after feedback has been delivered
    Given I have joined the session with the correct code
    When I select the choice "3" and submit my answer
    Then I should not see a "Resubmit" button until feedback arrives
    And once feedback arrives I should see a "Resubmit" button

  Scenario: A user who has not joined the session cannot resubmit
    Given a session is active for a question set
    But I have not joined the session
    When I attempt to resubmit an answer directly
    Then I should see an error indicating I am not part of the session
