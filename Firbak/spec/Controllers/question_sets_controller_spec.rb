require 'rails_helper'

RSpec.describe QuestionSetsController, type: :controller do
    before(:each) do
        if QuestionSet.where(id: 1000).empty?
            QuestionSet.create(
                id: 1000,
                questions: [1000, 2000]
                classes: "Math 101"
                )
        end
        if Question.where(id: 1000).empty?
            Question.create(
                id: 1000,
                number: 1,
                body: "What is 2 + 2?",
                choices: [1, 2, 3, 4],
                question_set_id: 1000,
            )
        end
        if Question.where(id: 2000).empty?
            Question.create(
                id: 2000,
                number: 2,
                body: "What is 2 * 3?",
                choices: [5, 6],
                question_set_id: 1000,
            )
        end
        if Choice.where(id: 1).empty?
            Choice.create(
                id: 1,
                body: "1",
                is_correct: false
                feedback: "Try again",
                question: 1000 
            )
        end
        if Choice.where(id: 2).empty?
            Choice.create(
                id: 2,
                body: "2",
                is_correct: false
                feedback: "Try again",
                question: 1000 
            )
        end
        if Choice.where(id: 3).empty?
            Choice.create(
                id: 3,
                body: "3",
                is_correct: false
                feedback: "Try again",
                question: 1000 
            )
        end
        if Choice.where(id: 4).empty?
            Choice.create(
                id: 4,
                body: "4",
                is_correct: true
                feedback: "Nice job!",
                question: 1000 
            )
        end
        if Choice.where(id: 1).empty?
            Choice.create(
                id: 1,
                body: "5",
                is_correct: false
                feedback: "Try again",
                question: 2000 
            )
        end
        if Choice.where(id: 2).empty?
            Choice.create(
                id: 2,
                body: "6",
                is_correct: false
                feedback: "Nice job",
                question: 2000 
            )
        end
    end

    describe 'Question Set/Question/Choice model validations and associations' do
        it 'questions belong to questions sets' do
            expect(Question[id=1000].question_set_id).to eq(1000)
        end

        it 'question sets can have multiple questions' do
            expect(QuestionSet[id=1000].questions.length).to eq(2)
        end

        it 'question sets belong to a class' do
            expect(QuestionSet[id=1000].class).to eq("Math 101")
        end

        it 'questions have at least one choice' do
            expect(Question[id=1000].choices.length).to be > 1
        end

        it 'choices belong to questions' do
            expect(Choice[id=1].question).to eq(1000)
        end
    end
end
