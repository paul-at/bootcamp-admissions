class AnswersController < ApplicationController
  # GET /answers
  # GET /answers.json
  def index
    @answers = Answer.where(app_form_id: params[:app_form_id])
  end
end
