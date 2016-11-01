# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Initialize ActionMailer after applicaion because Settings are not available until this point
Rails.application.config.action_mailer.delivery_method = :smtp
Rails.application.config.action_mailer.smtp_settings = Setting.smtp
Rails.application.config.action_mailer.default_options = Setting.mail_options
Rails.application.config.action_mailer.raise_delivery_errors = true
