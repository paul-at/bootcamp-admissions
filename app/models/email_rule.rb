class EmailRule < ApplicationRecord
  belongs_to :klass
  belongs_to :email_template

  validates :state, presence: true
  validates :klass_id, presence: true
  validates :email_template_id, presence: true

  def create_email_for(app_form)
    Email.create!(
      app_form: app_form,
      subject: email_template.subject,
      body: email_template.body,
      bcc: (copy_team ? app_form.klass.subscribers.join(', ') : nil),
    )
  end
end
