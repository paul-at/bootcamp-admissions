class Klass < ApplicationRecord
  belongs_to :subject
  has_many :app_forms

  validates :title, presence: true
end
