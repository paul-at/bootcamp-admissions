require 'quill_to_email'

class InterviewNote < ApplicationRecord
  belongs_to :app_form
  belongs_to :user

  include QuillToEmail

  def formatted_text
    quill_to_email read_attribute(:text)
  end
end
