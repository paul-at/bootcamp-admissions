require 'quill_to_email'

class Email < ApplicationRecord
  include QuillToEmail

  belongs_to :app_form
  belongs_to :user

  validates :subject, presence: true

  def merge
    self.body = Activerecord::Mergetags::Merge.merge(self.body, self.app_form)
  end

  def formatted_body
    quill_to_email read_attribute(:body)
  end
end
