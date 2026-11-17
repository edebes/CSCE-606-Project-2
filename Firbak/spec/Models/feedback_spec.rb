require 'rails_helper'

RSpec.describe Feedback, type: :model do
    #before(:each) do
    #    if Feedback.where(id: 1900).empty?
    #        Feedback.create!(
    #            to_user_id: 500,
    #            from_user_id: 501,
    #            session_id: 1000,
    #            question_id: 1,
    #            content: "Try again",
    #        )
    #    end
    #end

    it { is_expected.to belong_to(:to_user) }
    it { is_expected.to belong_to(:from_user) }
    it { is_expected.to belong_to(:session) }
    it { is_expected.to belong_to(:question) }
    it { is_expected.to validate_presence_of(:to_user) }
    it { is_expected.to validate_presence_of(:from_user) }
    it { is_expected.to validate_presence_of(:session) }
    it { is_expected.to validate_presence_of(:question) }
    it { is_expected.to validate_presence_of(:content) }


    describe 'deliver function' do
        xit 'delivers feedback to the user' do
            feedback = Feedback.find(1900)
            expect(feedback.deliver).to eq("Feedback delivered to user 500 for session 1000 and question 1000.")
        end
    end
end