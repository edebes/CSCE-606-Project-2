class ResponsesController < ApplicationController
   before_action :require_login
   before_action :set_session

   def create
     @question = @session.current_question_for(current_user)

     unless @question
       redirect_to session_path(@session), notice: "You have completed all questions in this session."
       return
     end
     @choice = @question.choices.find_by(id: params[:choice_id])
     @response = @session.submit_response(current_user, @question, @choice)

     case @response
     when Response
       message = @response.correct ? "Correct answer!" : "Incorrect answer."
       message += " Feedback: #{@choice.feedback}" if @choice&.feedback.present?
       redirect_to session_path(@session), notice: message
     when :ended
       redirect_to session_path(@session), alert: "This session has ended."
     when :not_participant
       redirect_to session_path(@session), alert: "You are not a participant in this session."
     when :invalid_question, :invalid_choice
       redirect_to session_path(@session), alert: "Invalid question or choice."
     end
   end

   private

   def set_session
     @session = Session.find(params[:session_id])
   end
 end