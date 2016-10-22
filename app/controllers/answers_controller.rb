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

  def update
    answer_ids = @app_form.answers.collect(&:id).map{|id| id.to_s.to_sym }
    answers = params.require(:answers).permit(answer_ids)
    answers.each do |id, answer|
      Answer.find(id).update(answer: answer)
    end
    redirect_to @app_form, notice: 'Answers updated.'
  end
end