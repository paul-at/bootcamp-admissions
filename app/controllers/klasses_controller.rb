class KlassesController < ApplicationController
  before_action :set_klass, only: [:edit, :update, :destroy]
  before_action do |controller|
    @settings_page = true
  end

  # GET /klasses
  # GET /klasses.json
  def index
    @klasses = Klass.all
  end

  # GET /klasses/new
  def new
    @klass = Klass.new
  end

  # GET /klasses/1/edit
  def edit
  end

  # POST /klasses
  def create
    @klass = Klass.new(klass_params)

    respond_to do |format|
      if @klass.save
        format.html { redirect_to klasses_url, notice: 'Class was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /klasses/1
  def update
    respond_to do |format|
      if @klass.update(klass_params)
        format.html { redirect_to klasses_url, notice: 'Class was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /klasses/1
  def destroy
    if @klass.app_forms.count == 0
      @klass.destroy
      redirect_to klasses_url, notice: 'Class was successfully destroyed.'
    else
      redirect_to klasses_url, notice: 'Unable to destroy class with applications.'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_klass
      @klass = Klass.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def klass_params
      params.require(:klass).permit(:subject_id, :title, :archived, :deposit, :tuition)
    end
end
