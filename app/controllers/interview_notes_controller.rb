class InterviewNotesController < ApplicationController
  load_and_authorize_resource :app_form
  before_action :set_interview_note, only: [:edit, :update]
  before_action :verify_app_form_id, only: [:edit]

  # GET /interview_notes/new
  def new
    @interview_note = InterviewNote.new
  end

  # GET /interview_notes/1/edit
  def edit
  end

  # POST /app_forms/:app_form_id/interview_notes.json
  def create
    success = InterviewNote.
      find_or_initialize_by(app_form: @app_form, user: current_user).
      update_attributes(text: params[:interview_note][:text])

    if success
      render json: nil, status: :created
    else
      render json: @interview_note.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /interview_notes/1
  # PATCH/PUT /interview_notes/1.json
  def update
    create
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interview_note
      @interview_note = InterviewNote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def interview_note_params
      params.require(:interview_note).permit(:app_form_id, :user_id, :text)
    end

    def verify_app_form_id
      raise "Access violation" unless @app_form.id == @interview_note.app_form_id
    end
end
