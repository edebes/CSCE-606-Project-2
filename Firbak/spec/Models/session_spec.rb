require 'rails_helper'

RSpec.describe Session, type: :model do
    before(:each) do
        if Session.where(id: 123456).empty?
            Session.create(
                id: 123456,
                user_id: 100,
                questionSet_id: 1000,
                context: "Created live session",
            )
        end
    end

    descibe 'created_session function' do
        it 'creates session for a question set' do
            session = Session.find(123456)
            expect(session.created_session).to eq("Session created with session ID 123456.")
        end
    end
end