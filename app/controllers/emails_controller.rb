class EmailsController < ApplicationController
  load_and_authorize_resource only: [:show, :edit]

  # GET /emails
  def index
    @emails = Email.where(sent: false)
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

    if params[:klass_id] && params[:state]  # Step 2 - pick recipients
      @app_forms = AppForm.where(klass_id: params[:klass_id], aasm_state: params[:state])
    elsif params[:app_form_ids]             # Step 3 - send emails
      @app_forms = AppForm.find(params[:app_form_ids])
      if @email.valid?
        @app_forms.each do |app_form|
          Email.create!(email_params.merge(app_form: app_form, user: current_user))
        end
        redirect_to emails_path, notice: 'E-mails were successfully queued for delivery.'
        return
      end
    end

    render :new
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def email_params
      params.require(:email).permit(:subject, :body, :copy_team)
    end
end
