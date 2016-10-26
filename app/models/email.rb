class Email < ApplicationRecord
  belongs_to :app_form
  belongs_to :user

  validates :subject, presence: true
end
