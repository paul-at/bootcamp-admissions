class AppFormsController < ApplicationController
  before_action :set_app_form, only: [:show, :update, :event, :payment, :comment, :delete, :restore]

  # Allow to file application from third-party website
  allow_cors :create, :new

  # GET /app_forms
  def index
    klass = Klass.find(params[:klass_id])
    authorize! :read, klass

    @title = params[:search].humanize
    @app_forms = klass.searches[params[:search].to_sym]
  end

  # GET /app_forms/deleted
  def deleted
    @title = 'Deleted Applications'
    @app_forms = AppForm.where(deleted:true).order(updated_at: :asc)
    render 'index'
  end

  # GET /app_forms/1
  def show
    authorize! :read, @app_form.klass

    if params[:search]
      @prevnext = Prev::Next.index(@app_form.klass.searches[params[:search].to_sym])
    end

    @history = @app_form.histories + @app_form.emails
    @history = @history.sort_by(&:created_at)
  end

  # GET /app_forms/new
  def new
    @app_form = AppForm.new
  end

  # POST /app_forms
  def create
    @app_form = AppForm.new(app_form_params)
    @app_form.payment_tier_id = @app_form.klass.payment_tier_id

    unless validate_uploads
      render plain: 'Attachment is too big, size limit ' + Rails.application.config.uploads_max_size.to_s
      return
    end

    if @app_form.save
      save_answers!
      save_uploads!
      @app_form.run_email_rules
      render plain: 'Application was successfully submitted.'
    else
      render json: @app_form.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /app_forms/1
  # PATCH/PUT /app_forms/1.json
  def update
    authorize! :read, @app_form.klass
    
    @app_form.assign_attributes(app_form_params)
    respond_to do |format|
      if @app_form.save
        log_change
        format.html { redirect_with notice: 'App form was successfully updated.' }
        format.json { render json: nil, status: :ok }
      else
        format.html { render :show }
        format.json { render json: @app_form.errors, status: :unprocessable_entity }
      end
    end
  end

  def event
    unless params[:event]
      redirect_with alert: 'Action not selected.'
      return
    end

    unless @app_form.aasm.events.map(&:name).include?(params[:event].to_sym)
      redirect_with alert: "Action #{params[:event]} is not available."
      return
    end

    begin
      @app_form.send(params[:event])
      @app_form.save!
      redirect_with
    rescue RuntimeError => e
      redirect_with(alert: 'Error: ' + e.inspect)
    end
  end

  def payment
    authorize! :read, @app_form.klass

    @app_form.paid = 0 unless @app_form.paid
    @app_form.paid += params[:paid].to_f
    @app_form.payment if @app_form.may_payment?
    @app_form.save!
    log_change
    redirect_with notice: 'Payment recorded.'
  end

  def comment
    History.create({
      app_form: @app_form,
      text: params[:note],
      user: current_user
    })
    redirect_with notice: 'Note recorded.'
  end

  def delete
    toggle_deleted(true)
  end

  def restore
    toggle_deleted(false)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app_form
      @app_form = AppForm.find(params[:id])
      @app_form.log_user = current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def app_form_params
      params.require(:app_form).permit(:klass_id, :firstname, :lastname, :email, :phone, :country, :residence, :city, :residence_city, :gender, :dob, :referral, :aasm_state, :payment_tier_id, :interviewer_id)
    end

    def save_answers!
      return unless params[:app_form][:answers]
      params[:app_form][:answers].each do |question, answer|
        Answer.create!(app_form: @app_form, question: question, answer: answer)
      end
    end

    def validate_uploads
      if params[:app_form][:uploads]
        params[:app_form][:uploads].each do |field, upload|
          if upload.size > Rails.application.config.uploads_max_size
            return false
          end
        end
      end
      return true
    end

    def save_uploads!
      return unless params[:app_form][:uploads]
      params[:app_form][:uploads].each do |field, upload|
        Attachment.create(app_form: @app_form, field: field, upload: upload)
      end
    end

    def log_change
      @app_form.previous_changes.each do |field, change|
        next if field == 'updated_at'
        if field == 'payment_tier_id'
          change.map! { |tier| tier.nil? ? 'None' : PaymentTier.find(tier).title }
        end
        History.create({
          app_form: @app_form, 
          text: "Field #{field.humanize}", 
          from: change[0],
          to: change[1],
          user: current_user,
        })
      end
    end

    def toggle_deleted(deleted)
      authorize! :delete, @app_form

      @app_form.deleted = deleted
      @app_form.save!
      log_change

      if deleted
        message = 'Application Form deleted.'
      else
        message = 'Application Form restored.'
      end

      redirect_with notice: message
    end

    def redirect_with(redirect_params = {})
      redirect_to app_form_path(@app_form, search: params[:search]), redirect_params
    end
end
