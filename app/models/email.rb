class Email < ApplicationRecord
  belongs_to :app_form
  belongs_to :user

  validates :subject, presence: true

  def merge
    self.body = Activerecord::Mergetags::Merge.merge(self.body, self.app_form)
  end
end
