class AppFormsController < ApplicationController
  before_action :set_app_form, only: [:show, :update]

  # Allow to file application from third-party website
  skip_before_action :verify_authenticity_token, :only => [:create]

  # GET /app_forms
  def index
    @app_forms = AppForm.searches[params[:search].to_sym].where(klass_id: params[:klass_id].to_i)
  end

  # GET /app_forms/1
  def show
  end

  # GET /app_forms/new
  def new
    @app_form = AppForm.new
  end

  # POST /app_forms
  def create
    @app_form = AppForm.new(app_form_params)

    if @app_form.save
      save_answers!
      render plain: 'Application was successfully submitted.'
    else
      render json: @app_form.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /app_forms/1
  # PATCH/PUT /app_forms/1.json
  def update
    respond_to do |format|
      if @app_form.update(app_form_params)
        format.html { redirect_to @app_form, notice: 'App form was successfully updated.' }
        format.json { render :show, status: :ok, location: @app_form }
      else
        format.html { render :edit }
        format.json { render json: @app_form.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app_form
      @app_form = AppForm.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def app_form_params
      params.require(:app_form).permit(:klass_id, :firstname, :lastname, :email, :country, :residence, :gender, :dob, :referral)
    end

    def save_answers!
      return unless params[:app_form][:answers]
      params[:app_form][:answers].each do |question, answer|
        Answer.create!(app_form: @app_form, question: question, answer: answer)
      end
    end
end
