class ImportController < ApplicationController
  before_action do |controller|
    authorize! :import, AppForm.class
    @settings_page = true
  end

  def index
  end

  def import
    @valid = Array.new
    @invalid = Array.new
    @warnings = Hash.new

    unless params[:csv] && params[:csv].tempfile
      @fatal = 'No CSV file selected'
      render 'index'
      return
    end

    begin
      CSV.parse(File.
          read(params[:csv].tempfile).
          force_encoding('BINARY').
          encode('UTF-8', :invalid => :replace, :undef => :replace, :replace => '?'),
          col_sep: ';') do |row|
        if @header_row
          import_row row
        else
          @header_row = row
        end
      end

      save_valid if params[:commit] == 'Import'
    rescue => e
      @fatal = e
    end 

    render 'index'
  end

  private
  def import_row(row)
    column = 0
    app_form_params = {}
    app_form_answers = []
    row.each do |value|
      if AppForm.attribute_names.include?(@header_row[column].downcase)
        app_form_params[@header_row[column].downcase] = value
      elsif value
        app_form_answers << Answer.new(question: @header_row[column], answer: value)
      end
      column += 1
    end

    ['dob', 'created_at', 'updated_at'].each do |date_field|
      if app_form_params[date_field]
        begin
          app_form_params[date_field] = DateTime.strptime(app_form_params[date_field], "%m/%d/%y %H:%M")
        rescue ArgumentError
          app_form_params[date_field] = Date.strptime(app_form_params[date_field], "%m/%d/%y")
        end
      end
    end

    app_form = AppForm.new(app_form_params)
    app_form.klass_id = params[:klass_id]

    guess_country_results = app_form.guess_country
    if guess_country_results.count > 0
      @warnings[app_form.full_email] = guess_country_results
    end

    if app_form.gender && app_form.gender.length > 1
      app_form.gender = app_form.gender[0].upcase
    end

    if app_form.valid?
      @valid << app_form
      app_form.answers = app_form_answers
    else
      @invalid << app_form
    end
  end

  def save_valid
    row = 0
    AppForm.transaction do
      @valid.each do |app_form|
        row += 1
        begin
          app_form.save!
          app_form.answers.each do |answer|
            answer.save!
          end
        rescue => e
          raise "Row #{row} <#{app_form.email}>: #{e}"
        end
      end
    end
  end
end
