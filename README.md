# Firbak

**Instant, targeted feedback for in-class problem solving.**

👉 **Try it:** https://YOUR-HEROKU-APP.herokuapp.com

Firbak is a web service that allows instructors to create practice tests/questions for students to answer. It also lets instructors enter feedback/corrections for incorrect answers so that if those answers are inputted, students can learn what went wrong and how to improve. This allows instructors to incorporate active learning to make sure their students are practicing the content, and the immediate feedback allows students to ensure they know what they need to learn and understand what they missed for the future.

---

## Why Firbak?

During an in-class worked example, some students work through the problem and some don't, and almost nobody raises a hand to share an answer in case it's wrong. Clicker tools show an instructor *who* got a question wrong, but not *why*, and the student is left guessing.

Firbak closes that gap:

- **Every student answers**, privately, from their own device.
- **A wrong answer explains itself.** Instructors write feedback for the common wrong answers ahead of time, so a student who picks one sees exactly what went wrong, right away.
- **Students work at their own pace**, moving to the next question once they get the current one right.
- **The instructor sees the room**: who's on which question, who's struggling, and at the end, which questions the class missed most.

---

## Who It's For

| You are... | You can... |
|---|---|
| **An instructor** | Run a live session on one of your question sets, watch everyone's progress, and review a summary of what the class got wrong |
| **A TA** | Join an instructor's session with its code to help during class |
| **A student** | Join with a code, answer at your own pace, and get feedback the moment you choose a wrong answer |

---

## Using Firbak

### As an instructor

**Start a session**
1. Log in and open **Question sets**.
2. Click **Start session** next to the set you want to use.
3. Share the **4-digit join code** shown on screen with your class.

**Follow along during class**
- Your session page lists everyone who has joined, the **question they're on**, and whether they're **struggling** (their last answer was wrong).
- Click **Refresh** to see the latest progress.

**End the session and review the results**
1. Click **End session** when you're done. Students can't submit answers after this.
2. You'll see the **Session summary**:
   - **Most missed:** questions ranked by how many students got them wrong.
   - **Each question:** how many students got it right (for example, "2 of 3 correct") and how many picked each choice, with the correct answer marked.
3. The summary counts each student's **first attempt** at a question, so you see what the class really got wrong, not what they fixed after reading the feedback.

You can reopen the summary any time from the ended session's page with **View session summary**.

### As a student

**Join a session**
1. Log in and click **Join session**.
2. Enter the code your instructor gives you and click **Join**.
   - If the code is wrong, you'll see **"Invalid session code"**. Check it and try again.
   - If the session is already over, you'll see **"Session has ended"**.

**Answer questions**
1. You'll see one question at a time, like "Question 1 of 3".
2. Pick an answer and click **Submit**.
   - **Right:** you'll see **"Correct!"** and move on to the next question.
   - **Wrong:** you'll see **"Not quite."**, plus your instructor's explanation for that answer if they wrote one. Read it and try the question again.
3. Your feedback stays on the page if you refresh, and only you can see it.
4. When you've answered everything, you'll see **"You have completed all questions in this session."**

### As a TA
1. Log in and click **Join session**.
2. Enter the session's code to join your instructor's session.

---

## Good to Know

- **No app to install.** Firbak runs in any web browser on a laptop, tablet or phone.
- **Works without JavaScript.** Every page is a plain form, so it works on locked-down or older devices. Pages show new information when you refresh them.
- **Your answers are private.** Other students never see what you chose or the feedback you got. Only the instructor sees everyone's progress and the class results.
- **One session, one code.** Each live session gets its own code, so students can't land in the wrong class by accident.

### Coming soon
- **Build question sets in Firbak:** write your own questions, answer choices and feedback directly in the app.
- **Live feedback:** instructors and TAs will be able to send a short message to an individual student during a session.

---

## Try It With Sample Accounts

The demo site comes with sample accounts. All use the password **`password123`**.

| Role | Email |
|---|---|
| Instructor | `anne.smith@tamu.edu` |
| Student | `john.doe@tamu.edu` |
| TA | `alfonzo.rebeiro@tamu.edu` |

Log in as the instructor in one browser window and as the student in a private window, then start a session on **Basic Math** and join it.

---

## Running Firbak Yourself

Requires Ruby 3.4.10, Bundler and SQLite.

```bash
git clone https://github.com/edebes/CSCE-606-Project-2.git
cd CSCE-606-Project-2/Firbak
bundle install
bin/rails db:prepare db:seed
bin/rails server
```

Then open http://localhost:3000 and log in with one of the sample accounts above.

---

## About

Built by Alex Gonce, Eric Debes, Gokulan Valavan, Jaelen Dixon and Yashas Suresh for CSCE 606 (Software Engineering) at Texas A&M University.
