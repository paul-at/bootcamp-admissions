class Vote < ApplicationRecord
  belongs_to :app_form
  belongs_to :user

  def self.casted_in(klass)
    where(app_form: klass.app_forms.where(aasm_state: 'applied')).group(:user_id).count
  end
end
