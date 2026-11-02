require 'rails_helper'

RSpec.describe Feedback, type: :model do
    before(:each) do
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

    descibe 'deliver_to function' do
        it 'delivers feedback to the user' do
            feedback = Feedback.find(1900)
            expect(feedback.deliver_to).to eq("Feedback delivered to user 500 for session 1000 and question 1000.")
        end
    end
end