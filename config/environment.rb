# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Make sure latest settings are being used for email sending
Rails.cache.clear

# Initialize ActionMailer after applicaion because Settings are not available until this point
ApplicationMailer.delivery_method = :smtp
ApplicationMailer.smtp_settings = Setting.smtp
ApplicationMailer.default_options = Setting.mail_options
ApplicationMailer.raise_delivery_errors = true
Devise::Mailer.smtp_settings = Setting.smtp
