class Score < ApplicationRecord
  belongs_to :app_form
  belongs_to :user

  validates :app_form, presence: true
  validates :user, presence: true
end
