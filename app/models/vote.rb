class Vote < ApplicationRecord
  belongs_to :app_form
  belongs_to :user
end
