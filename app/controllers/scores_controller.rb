class ScoresController < ApplicationController
  before_action :set_app_form, only: [:index, :create, :edit]

  # GET /app_forms/:app_form_id/scores
  def index
    set_app_form
  end

  # GET /app_forms/:app_form_id/scores/1/edit
  def edit
    authorize! :score, @app_form
  end

  # POST /app_forms/:app_form_id/scores
  def create
    authorize! :score, @app_form

    params[:user_scores][:scores_attributes].values.each do |score|
      if Integer(score[:app_form_id]) != @app_form.id
        raise "Security violation. Provided app_form_id #{score[:app_form_id]} doesn't match #{@app_form.inspect}"
      end
    end

    scores = UserScores.new([], current_user)
    scores.create_or_update!(params[:user_scores][:scores_attributes])
    redirect_to app_form_scores_url, notice: 'Scores were successfully recorded.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app_form
      @app_form = AppForm.find(params[:app_form_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def score_params
      params.require(:score).permit(:app_form_id, :user_id, :criteria, :score, :reason)
    end
end
