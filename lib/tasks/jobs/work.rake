namespace :jobs do
  desc "Email delivery loop"
  task work: :environment do
    Rails.application.config.action_mailer.delivery_method = :smtp
    Rails.application.config.action_mailer.smtp_settings = Setting.smtp
    Rails.application.config.action_mailer.default_options = Setting.mail_options
    Rails.application.config.action_mailer.raise_delivery_errors = true

    while true
      begin
        DeliverMailJob.perform_now
      rescue Exception => e
        Rails.logger.error(e)
      end
      sleep 30
    end
  end
end
