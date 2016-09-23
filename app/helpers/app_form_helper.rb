module AppFormHelper
  def link_to_scores(app_form)
    link_to "<big>#{app_form.average_score}</big> <small>/ #{app_form.klass.max_score}</small>".html_safe,
      app_form_scores_path(app_form_id: app_form.id)
  end
end