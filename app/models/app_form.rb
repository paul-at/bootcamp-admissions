class AppForm < ApplicationRecord
  include AASM

  belongs_to :klass
  has_many :answers

  aasm enum: false do
    state :applied, initial: true
    state :decided_to_invite, :rejected, :invite_email_sent
    state :interview_scheduled, :interviewed, :unable_to_interview
    state :admitted, :waitlisted, :extension, :scholarship, :deposit_paid, :tuition_paid

    event :invite do
      transitions from: :applied, to: :decided_to_invite
    end

    event :send_email do
      transitions from: :decided_to_invite, to: :invite_email_sent
    end

    event :reject do
      transitions from: [ :applied ], to: :rejected
      transitions from: [ :interviewed, :waitlisted ], to: :rejected
    end

    event :schedule_interview do
      transitions from: [ :decided_to_invite, :invite_email_sent ], to: :interview_scheduled
    end

    event :interview do
      transitions from: :interview_scheduled, to: :interviewed
    end

    event :cancel do
      transitions from: [ :decided_to_invite, :invite_email_sent, :interview_scheduled ], to: :unable_to_interview
      transitions from: [ :admitted, :waitlisted, :extension, :scholarship, :deposit_paid, :tuition_paid ], to: :rejected
    end

    event :admit do
      transitions from: [ :interviewed, :waitlisted ] , to: :admitted
    end

    event :waitlist do
      transitions from: :interviewed, to: :waitlisted
    end

    event :grant_extension do
      transitions from: :admitted, to: :extension
    end

    event :grant_scholarship do
      transitions from: :admitted, to: :scholarship
    end

    event :payment do
      transitions from: [ :admitted, :deposit_paid, :extension ], to: :tuition_paid # TODO:, guard: paid_for?(bootcamp.tuition)
      transitions from: :admitted, to: :deposit_paid # TODO:, guard: paid_for?(bootcamp.deposit)
      transitions from: :admitted, to: :admitted
      transitions from: :deposit_paid, to: :deposit_paid
      transitions from: :tuition_paid, to: :tuition_paid
      transitions from: :extension, to: :extension
    end

    event :revert do
      transitions from: [ :decided_to_invite, :rejected ], to: :applied
      transitions from: [ :interview_scheduled, :unable_to_interview, :interviewed ], to: :decided_to_invite
      transitions from: [ :admitted, :waitlisted ], to: :interviewed
      # TODO: add transition from cancelled to deposit_paid or tuition_paid if balance is enough
      transitions from: [ :scholarship, :extension ], to: :admitted
    end
  end

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, presence: true
  validates :country, presence: true, length: { is: 2 }
  validates :residence, presence: true, length: { is: 2 }
  validates :gender, presence: true, length: { is: 1 }
  validates :dob, presence: true
  validates :terms_and_conditions, acceptance: true

  # scopes available for external querying
  def self.searches
    {
      applied: self.all,
      today: self.where('created_at >= ?', Date.today),
      new: self.where('aasm_state = ?', :applied),

      invited: self.where('aasm_state in (?)', [:invite_email_sent, :interview_scheduled, :unable_to_interview, :interviewed, :waitlisted, :admitted, :scholarship, :deposit_paid, :extension, :tuition_paid]),
      rejected: self.where('aasm_state = ?', :rejected),
      invite_emails_pending: self.where('aasm_state = ?', :decided_to_invite),

      interviewed: self.where('aasm_state in (?)', [:interviewed, :waitlisted, :admitted, :scholarship, :deposit_paid, :extension, :tuition_paid]),
      waitlist: self.where('aasm_state = ?', :waitlisted),
      interviews_scheduled: self.where('aasm_state = ?', :interview_scheduled),

      admitted_and_coming: self.where('aasm_state in (?)', [:admitted, :scholarship, :deposit_paid, :extension, :tuition_paid]),
      scholarships_granted: self.where('aasm_state = ?', :scholarship),
      deposit_pending: self.where('aasm_state = ?', :admitted),
      tuition_pending: self.where('aasm_state in (?)', [:admitted, :deposit_paid]),
      extensions: self.where('aasm_state = ?', :extension)
    }
  end
end
