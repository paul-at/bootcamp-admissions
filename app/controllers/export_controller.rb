class ExportController < ApplicationController
  before_action do |controller|
    authorize
    @settings_page = true
  end

  def index
    @classes = Klass.all.includes(:subject).order('subjects.title, klasses.title')
  end

  def app_forms
    send_data AppForm.where(klass_id: params[:klasses].map{|c| c.to_i}).to_csv,
      filename: 'app_forms.csv',
      type: 'text/csv'
  end

  private
  def authorize
    authorize! :export, AppForm.new
  end
end
