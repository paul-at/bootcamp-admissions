class PaymentTiersController < ApplicationController
  before_action :set_payment_tier, only: [:show, :edit, :update, :destroy]
  before_action do |controller|
    @settings_page = true
  end

  # GET /payment_tiers
  # GET /payment_tiers.json
  def index
    authorize! :manage, PaymentTier
    @payment_tiers = PaymentTier.all
  end

  # GET /payment_tiers/1
  # GET /payment_tiers/1.json
  def show
  end

  # GET /payment_tiers/new
  def new
    @payment_tier = PaymentTier.new
  end

  # GET /payment_tiers/1/edit
  def edit
  end

  # POST /payment_tiers
  # POST /payment_tiers.json
  def create
    @payment_tier = PaymentTier.new(payment_tier_params)
    authorize! :manage, @payment_tier

    respond_to do |format|
      if @payment_tier.save
        format.html { redirect_to @payment_tier, notice: 'Payment tier was successfully created.' }
        format.json { render :show, status: :created, location: @payment_tier }
      else
        format.html { render :new }
        format.json { render json: @payment_tier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payment_tiers/1
  # PATCH/PUT /payment_tiers/1.json
  def update
    respond_to do |format|
      if @payment_tier.update(payment_tier_params)
        format.html { redirect_to @payment_tier, notice: 'Payment tier was successfully updated.' }
        format.json { render :show, status: :ok, location: @payment_tier }
      else
        format.html { render :edit }
        format.json { render json: @payment_tier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_tiers/1
  # DELETE /payment_tiers/1.json
  def destroy
    @payment_tier.destroy
    respond_to do |format|
      format.html { redirect_to payment_tiers_url, notice: 'Payment tier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment_tier
      @payment_tier = PaymentTier.find(params[:id])
      authorize! :manage, @payment_tier
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_tier_params
      params.require(:payment_tier).permit(:title, :deposit, :tuition)
    end
end
