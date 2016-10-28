class EmailRulesController < ApplicationController
  load_and_authorize_resource only: [:show, :edit, :update, :destroy]
  before_action do |controller|
    @settings_page = true
  end

  # GET /email_rules
  def index
    @email_rules = EmailRule.all.includes(klass: :subject).order('subjects.title, klasses.title, state')
  end

  # GET /email_rules/1
  def show
  end

  # GET /email_rules/new
  def new
    @email_rule = EmailRule.new
  end

  # GET /email_rules/1/edit
  def edit
  end

  # POST /email_rules
  def create
    @email_rule = EmailRule.new(email_rule_params)

    respond_to do |format|
      if @email_rule.save
        format.html { redirect_to @email_rule, notice: 'Email rule was successfully created.' }
        format.json { render :show, status: :created, location: @email_rule }
      else
        format.html { render :new }
        format.json { render json: @email_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /email_rules/1
  def update
    respond_to do |format|
      if @email_rule.update(email_rule_params)
        format.html { redirect_to @email_rule, notice: 'Email rule was successfully updated.' }
        format.json { render :show, status: :ok, location: @email_rule }
      else
        format.html { render :edit }
        format.json { render json: @email_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /email_rules/1
  def destroy
    @email_rule.destroy
    respond_to do |format|
      format.html { redirect_to email_rules_url, notice: 'Email rule was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def email_rule_params
      params.require(:email_rule).permit(:klass_id, :state, :email_template_id, :copy_team)
    end
end
