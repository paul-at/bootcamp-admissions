class DeliverMailJob < ApplicationJob
  queue_as :default

  def perform(*args)
    queue = Email.where(sent: false)
    queue.each do |email|
      send_email(email)
    end
  end

private
  def send_email(email)
    email.sent_to = email.app_form.full_email
    ApplicationMailer.rendered_email(email.sent_to, email.subject, email.body).deliver
    email.sent = true
    email.save!

    if email.app_form.may_email_sent?
      email.app_form.email_sent
      email.app_form.save!
    end
  end
end
