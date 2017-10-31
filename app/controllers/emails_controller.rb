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

    if params[:email_template_id] && params[:email_template_id].to_i > 0
      template = EmailTemplate.find(params[:email_template_id])
      @email.body = template.body
      @email.subject = template.subject
    end

    if ['Preview','Test E-mail Myself'].include?(params[:commit]) # Step 2 - pick recipients
      @app_forms = AppForm.visible.where(klass_id: params[:klass_id], aasm_state: params[:state])
      @klass = Klass.find(params[:klass_id])

      deliver_test_email if params[:commit] == 'Test E-mail Myself'
    elsif params[:app_form_ids]     # Step 3 - send emails
      if params[:commit] == 'Send E-mails' && @email.valid?
        @app_forms = AppForm.find(params[:app_form_ids])
        @app_forms.each do |app_form|
          Email.create!(email_params.merge(app_form: app_form, user: current_user))
        end
        redirect_to emails_path, notice: 'E-mails were successfully queued for delivery.'
        return
      end
    end

    render :new
  end

  # GET /email/mergetags
  def mergetags
    @mergetags = generate_mergetags_for(AppForm.last).flatten.compact
    render layout: false
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def email_params
      params.require(:email).permit(:subject, :body, :cc, :bcc)
    end

    def generate_mergetags_for(obj, path = '')
      return nil unless obj
      obj.attributes.keys.map do |attribute|
        if /_id$/.match(attribute)
          association = attribute.gsub(/_id$/, '')
          generate_mergetags_for(obj.send(association), path + association.upcase + '.')
        else
          "*|#{path}#{attribute.upcase}|*"
        end
      end
    end

    def deliver_test_email
      ApplicationMailer.rendered_email({
        to: current_user.email,
        subject: @email.subject,
        body: @email.formatted_body,
      }).deliver
      flash.now.notice = 'A test e-mail has been sent to ' + current_user.email
    end
end
