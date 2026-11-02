require 'rails_helper'

RSpec.describe FeedbacksController, type: :controller do
    before(:each) do
        if User.where(id: 500).empty?
            User.create(
                id: 500,
                name: "John",
                email: "john@gmail.com",
                role: "student",
                )
        end
        if Question.where(id: 1000).empty?
            Question.create(
                id: 1000,
                number: 1,
                body: "What is 2 + 2?",
                choices: [1, 2, 3, 4],
                question_set_id: 2000,
            )
        end
        if Choice.where(id: 2).empty?
            Choice.create(
                id: 2,
                body: "3",
                is_correct: false
                feedback: 1900,
            )
        end
        if Feedback.where(id: 1900).empty?
            Feedback.create(
                id: 1900,
                to_user_id: 500,
                session_id: 1000,
                question_id: 1000,
                context: "Try again",
                delivered: "2024-06-01 00:00:00",
            )
        end
    end

    describe 'when receiving feedback on an incorrect choice' do
        it 'delivers feedback to the user' do
            # enter in more logic about sending user choice and receiving feedback
            expect(response).to have_http_status(:success)
        end

        it 'does not deliver feedback to the user if the choice is correct' do
            # enter in more logic about sending user choice and receiving feedback
            expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not deliver feedback to the user if the choice does not exist' do
            # enter in more logic about sending user choice and receiving feedback
            expect(response).to have_http_status(:not_found)
        end
    end
end
