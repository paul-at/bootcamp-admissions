module AppFormHelper
  def link_to_scores(app_form)
    link_to "<big>#{app_form.average_score}</big> <small>/ #{app_form.klass.max_score}</small>".html_safe,
      app_form_scores_path(app_form_id: app_form.id)
  end

  def event_name(event)
    t event, scope: [:activerecord, :attributes, :app_form, :event_names], raise: true
  rescue I18n::MissingTranslationData => e
    event.to_s.humanize
  end

  def uri?(string)
    uri = URI.parse(string)
    %w( http https ).include?(uri.scheme)
  rescue URI::BadURIError
    false
  rescue URI::InvalidURIError
    false
  end

  def short_date(dt)
    dt.strftime('%b %d, %Y')
  end
end