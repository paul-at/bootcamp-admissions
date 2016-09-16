class PaymentTier < ApplicationRecord
  validates :title, presence: true

  has_many :klasses
end
