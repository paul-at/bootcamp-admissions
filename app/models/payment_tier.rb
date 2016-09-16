class PaymentTier < ApplicationRecord
  validates :title, presence: true

  has_many :klasses

  def self.list_for_select
    [['None',nil]] + all.map { |tier| [tier.title, tier.id] }
  end
end
