class AnswersController < ApplicationController
  load_and_authorize_resource :app_form

  def new
    @answer = Answer.new
  end

  def create
    @answer = Answer.new(
      app_form: @app_form,
      question: params[:answer][:question],
      answer: params[:answer][:answer],
    )
    if @answer.save
      redirect_to @app_form, notice: 'Answer stored.'
    else
      render :new
    end
  end
end