class EmailRule < ApplicationRecord
  belongs_to :klass
  belongs_to :email_template

  validates :state, presence: true
  validates :klass_id, presence: true
  validates :email_template_id, presence: true
end
