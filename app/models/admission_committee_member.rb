class AdmissionCommitteeMember < ApplicationRecord
  belongs_to :user
  belongs_to :klass
end
