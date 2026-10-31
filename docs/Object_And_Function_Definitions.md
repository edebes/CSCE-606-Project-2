## Models

**User**  
*Attributes:*
- id
- name
- email
- role (instructor, TA, student)
- progression (for stretch)

*Functions:*
- role?(): Checks the user's role (instructor, TA, student).
- can_manage_sets?(): Determines if a user has permission to create/edit question sets.
- can_give_live_feedback?(): Determines if the user (instructor/TA) can send live feedback.
- track_progress(class_id, question_set_id): Returns or updates the student’s progression stats for given classes/sets (stretch).

---

**Class**  
*Attributes:*
- id
- name
- instructors (association to User)
- tas (association to User, with permission levels for stretch)
- students (association to User)

*Functions:*
- add_member(user, role): Adds a user to the class with a specific role.
- remove_member(user): Removes a user from the class.
- assign_ta_permission(user, permission_level): Sets TA permission level for a user (stretch).
- class_statistics(): Returns aggregate data such as question performance or participation.
- enrolled_students(): Returns all students enrolled in the class.

---

**QuestionSet**  
*Attributes:*
- id
- name/title
- owner (instructor User)
- questions (association to Question)
- shared_with (instructors this set is shared with, stretch)

*Functions:*
- add_question(question): Adds a question to the set.
- remove_question(question): Removes a question from the set.
- launch_session(): Initiates a new in-class session with this set.
- share_with(user): Shares this set with another instructor (stretch).
- questions(): Returns all questions associated with the set.

---

**Question**  
*Attributes:*
- id
- number
- body (text)
- choices (association to Choice)
- topics (association to Topic, stretch)
- question_sets (association to QuestionSet)

*Functions:*
- add_choice(choice): Adds an answer choice to the question.
- remove_choice(choice): Removes an answer choice.
- categorize_topic(topic): Assigns the question to a topic (stretch).
- choices(): Returns all associated choices.
- correct_choice(): Returns the correct choice for the question

---

**Choice**  
*Attributes:*
- id
- body (text)
- correct (boolean)
- feedback (text)

*Functions:*
- correct?(): Returns true if the choice is the correct answer.
- feedback_for_selection(): Returns the pre-programmed instructor feedback for this choice.

---

**Session**  
*Attributes:*
- id
- question_set_id
- host (instructor User)
- code (session join code)
- participants (users)
- status (active/ended)
- responses (collection of answers per student)
- summary (answers/most-missed questions)

*Functions:*
- start(): Begins a new session, generates join code.
- end(): Ends the session and compiles results.
- join(user, code): Adds a participant to the session if the code is valid.
- send_live_feedback(student, feedback): Delivers additional (real-time) feedback to a student.
- allow_resubmission(student, question): Enables a student to resubmit after feedback.
- session_summary(): Returns results, highlighting most missed questions and common errors.

---

**Feedback**  
*Attributes:*
- id
- to_user_id
- session_id
- question_id
- content (text)
- delivered (boolean/timestamp)

*Functions:*
- deliver_to(student): Sends feedback to targeted student.

---

**Topic** (stretch)  
*Attributes:*
- id
- name
- questions (association)

*Functions:*
- questions_missed_stats(class_id, question_set_id): Returns stats on missed questions in this topic.

---

**Statistics** (module/concern)  
*Functions:*
- most_missed_questions(session_id): Returns most missed questions for a session.
- topic_performance(class_id, question_set_id): Returns statistics per topic (stretch).

## Controllers

**QuestionSetsController**  
*Functions:*
   - create(): Handles creation of new question sets by instructors.
   - update(): Manages editing/updating of question sets, including adding/removing questions.
   - destroy(): Deletes a question set.
   - launch_session(): Custom action to start a new classroom session with a specific question set.

**SessionsController**  
*Functions:*
   - join(): Validates session code for students/TAs joining, flashes errors for incorrect codes.
   - send_feedback(): Allows instructor/TA to send live feedback to a student during an active session.
   - resubmit(): Enables a student to submit a new answer to a question after feedback.
   - summary(): Returns session statistics, most-missed questions, and common mistakes when ended.

**FeedbacksController**  
*Functions:*
   - deliver(): Sends specific, real-time feedback to a student (possibly via ActionCable/WebSockets).


## View Helpers

**FeedbackHelper**  
*Functions:*
   - feedback_for_choice(choice): Returns the formatted feedback message for a selected choice.
   - live_feedback_tag(student, question): Injects dynamic elements to display live feedback as it arrives (using a stimulus controller or a JS hook).

**SessionsHelper**  
*Functions:*
   - error_message_for_join(flash): Displays error messages when a student enters a wrong session code.
   - session_summary_table(summary): Creates a table layout of question performance for the instructor.

**QuestionSetsHelper**  
*Functions:*
   - question_list_with_feedback(question_set): Generates an interactive list of all questions in a set, with indicators for feedback available.

**ResubmissionHelper**  
*Functions:*
   - resubmit_button(question, student_attempt): Displays a resubmit button if eligible, wired to the appropriate controller action via AJAX.
