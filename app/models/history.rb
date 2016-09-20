class History < ApplicationRecord
  belongs_to :app_form
  belongs_to :user, optional: true

  # Order by the order of creation
  default_scope { order(:id) }
end
