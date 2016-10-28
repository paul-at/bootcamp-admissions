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
    if email.copy_team
      bcc = email.app_form.klass.subscriptions.map { |subscription| subscription.user.email }
    else
      bcc = []
    end
    ApplicationMailer.rendered_email(to: email.sent_to, subject: email.subject, body: email.body, bcc: bcc).deliver
    email.sent_to += ',' + bcc.join(',') unless bcc.empty?
    email.sent = true
    email.save!

    if email.app_form.may_email_sent?
      email.app_form.email_sent
      email.app_form.save!
    end
  end
end
