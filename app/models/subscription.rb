class Subscription < ApplicationRecord
  belongs_to :klass
  belongs_to :user
end
