class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  def rendered_email(params)
    mail({ content_type: 'text/html' }.merge(params))
  end
end
