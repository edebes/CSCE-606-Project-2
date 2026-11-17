# Sprint 1: Oct 23-Nov 1
## Goal: Write test coverage
Backlog created in github projects

## Sprint Meetings
### Sprint Planning 10/23
Attendees: Alex Gonce, Eric Debes, Jaelen Dixon, Yashas Suresh

Summary: Discussed ideas of how to break up sprints, finalized initial plan for first 2 sprints, created backlog and assigned points

### Scrum Meeting 10/26
Attendees: Alex Gonce, Eric Debes, Gokulan Valavan

Summary: Discussed updates, of which there were done

### Scrum Meeting 10/28
Attendees: Eric Debes, Jaelen Dixon, Gokulan Valavan

Summary: Began divvying out tasks among attendees

### Scrum Meeting 10/30
Attendees: Alex Gonce, Jaelen Dixon, Eric Debes

Summary: Alex claimed tasks

### Sprint Review 11/2
Attendees: Alex Gonce, Gokulan Valavan, Eric Debes, Jaelen Dixon, Dr. Ritchey

Notes:
- goal was to write tests for the project
- showed Dr. Ritchey the tests
- try not to do “should not” tests
- more domain relevance question
- ^ (student receiving feedback feature)
- make sure to split work vertically, ~1 model/person

### Sprint Retrospective 11/2
Attendees: Alex Gonce, Gokulan Valavan, Eric Debes, Jaelen Dixon

Notes:
- PR were mostly self-reviewed this time around, but in the future we should make sure others review
- others should review PRs within 1-2 days
- Sprint time frames should be flexible given the scope of the work

# Sprint 2: Nov 2-Nov 15
## Goal: Finish MVP and Deploy
## Sprint Meetings
### Sprint Planning 11/2
Attendees: Alex Gonce, Eric Debes, Yashas Suresh, Gokulan Valavan

Notes: 

Everyone agreed to sprint goal

1st scrum meeting goal: have logic largely implemented for each of these models and deploy

- User: Eric (3 points)
- Class: Gokulan (3 points)
- QuestionSet: Alex (3 points)
- Question & Choice:  (3 points)
- Session:  (3 points)

Points for user stories will be assigned to multiple people since they are mostly cross-model, if anyone needs to do a particularly significant amount of work to get a user story to complete, they will get most of the points the story is worth, but we plan to do much more paired programming this sprint to share the story points of the user stories.

### Scrum Meeting 11/4
Attendees: Eric Debes, Alex Gonce, Jaelen Dixon

Summary: Everyone was busy, no work complete

### Scrum Meeting 11/6
Attendees: Alex Gonce, Gokulan Valavan, Eric Debes, Jaelen Dixon, Yashas Suresh

Summary: 
- talked about backend/database
- Eric, Alex, Jaelen completed models
- Mini-Goal: Deploy application over weekend

### Scrum Meeting 11/9
Attendees: Alex Gonce, Gokulan Valavan, Eric Debes, Jaelen Dixon

Summary: 
- reviewing PRs going well
- current rate feels like good progress

### Scrum Meeting 11/11
Attendees: Alex Gonce, Gokulan Valavan, Eric Debes, Jaelen Dixon

Summary: 
- DEPLOYED!
- readjusting story points/user stories since Yashas completed more than assigned
- needing to catch up main (open pull requests)

### Scrum Meeting 11/13
Attendees: Alex Gonce, Eric Debes, Jaelen Dixon

Summary: 
- Jaelen and Alex busy, Eric made outline for his tasks
- going back questions is stretch goal
- add questions tracker to Session model
- check if not Gokulan can push to Heroku/can we make github action to automate it
- Discussion: how to not have javascript, 
  - solo session for student? - stretch goal
  - students can just all go at their own pace
  - Decision: need to refresh page for live feedback if no javascript
- QuestionSet belongs to one user, belongs to many classes - Alex
- update README for running project - Gokulan

### Sprint Review & Retrospective 11/15
Attendees: Alex Gonce, Eric Debes, Jaelen Dixon, Gokulan Valavan, Sapphire

Summary: 
- demoed current project state to Sapphire
  - looks good for what it currently does
  - can’t have same student join multiple times, good
- reviewed expectations of attendance at scrum meetings
- discussed being more conscious of tasks story points worth and being more clear about expectations with high value stories
- reviewing some of the final PRs for the sprint
- review story dependences during sprint planning & still try to pre-assign tasks but be more communicative if high priority/relevancy tasks aren’t getting done

### In-class review 11/16
Summary:
- Group 1
  - logged in as student
  - joined a session
  - returning to a session is same as joining a session
  - logged in as teacher
  - get a new join code every time they hit “new session” for a question set
  - it shouldn’t say live if teacher joins session that should be dead
- Suggestions
  - make sessions persistent in the database
  - it seems like rejoining a session is same as joining a session
- Group 2
  - logged in as student
  - join codes are made randomly, checking against currently in use codes

# Sprint 3: Nov 16-Nov 29
## Goal: Finish MVP features & style project
## Sprint Meetings
### Sprint Planning 11/16
Attendees: Alex Gonce, Jaelen Dixon, Yashas Suresh, Gokulan Valavan

Notes: 

Suggested backlog: (edited as discussed during meeting)
- add CSS to all pages
- separate tasks for most each page
- add user registration page (can only create students accounts)
- add page for profs to view all courses/students
- add to that page buttons to upgrade roles (student -> ta or prof)
- each question will have its own edit page
- need to make sure adding a new question button is added

User Stories Backlog added to projects

Sprint may end end early but there's thanksgiving break so there may be break between sprints

If someone has extra time, start work on presentation/start plan on demo
