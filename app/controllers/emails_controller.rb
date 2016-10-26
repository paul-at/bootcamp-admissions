class EmailsController < ApplicationController
  load_and_authorize_resource only: [:show, :edit]

  # GET /emails
  def index
    @emails = Email.all
  end

  # GET /emails/1
  def show
  end

  # GET /emails/new
  def new
    @email = Email.new
  end

  # POST /emails
  def create
    @email = Email.new(email_params)

    respond_to do |format|
      if @email.save
        format.html { redirect_to @email, notice: 'Email was successfully queued for delivery.' }
        format.json { render :show, status: :created, location: @email }
      else
        format.html { render :new }
        format.json { render json: @email.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def email_params
      params.require(:email).permit(:subject, :body, :app_form_id, :copy_team)
    end
end
