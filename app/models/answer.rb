class Answer < ApplicationRecord
  belongs_to :app_form

  validates :question, presence: true
end
