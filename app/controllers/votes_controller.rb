class VotesController < ApplicationController
  before_action :set_app_form, only: :index
  before_action :set_vote, only: [:show]

  # GET /app_forms/:app_form_id/votes
  def index
    @votes = @app_form.votes
  end

  # POST /app_forms/:app_form_id/votes
  def create
    @vote = Vote.new(vote_params.merge(user: current_user))

    if @vote.save
      head :no_content
    else
      render json: @vote.errors, status: :unprocessable_entity
    end
  end

  # DELETE /app_forms/:app_form_id/votes
  def destroy
    Vote.where(app_form_id: params[:app_form_id], user: current_user).delete_all
    head :no_content
  end

  private
    def set_app_form
      @app_form = AppForm.find(params[:app_form_id])
    end

    def set_vote
      @vote = Vote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vote_params
      params.permit(:app_form_id, :vote)
    end
end
