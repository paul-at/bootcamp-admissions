class AppForm < ApplicationRecord
  include AASM

  belongs_to :klass
  has_many :answers

  aasm enum: false do
    state :applied, initial: true
    state :decided_to_invite, :invite_email_sent, :decided_to_reject_application, :application_reject_email_sent
    state :interview_scheduled, :interviewed, :rejected_after_interview, :unable_to_interview
    state :admitted, :waitlisted, :extension, :deposit_paid, :tuition_paid, :not_coming
    state :scholarship_shortlisted, :scholarship_granted

    event :invite do
      transitions from: :applied, to: :decided_to_invite
    end

    event :email_sent do
      transitions from: :decided_to_invite, to: :invite_email_sent
      transitions from: :decided_to_reject_application, to: :application_reject_email_sent
    end

    event :reject do
      transitions from: [ :applied, :decided_to_invite ], to: :decided_to_reject_application
      transitions from: [ :interviewed, :waitlisted ], to: :rejected_after_interview
    end

    event :schedule_interview do
      transitions from: [ :decided_to_invite, :invite_email_sent ], to: :interview_scheduled
    end

    event :interview do
      transitions from: :interview_scheduled, to: :interviewed
    end

    event :reschedule do
      transitions from: [ :interview_scheduled, :unable_to_interview ], to: :interview_scheduled
    end

    event :wont_come do
      transitions from: [ :decided_to_invite, :invite_email_sent, :interview_scheduled ], to: :unable_to_interview
      transitions from: [ :admitted, :waitlisted, :extension, :scholarship_granted, :deposit_paid, :tuition_paid ], to: :not_coming
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

    event :shortlist_for_scholarship do
      transitions from: :admitted, to: :scholarship_shortlisted
    end

    event :grant_scholarship do
      transitions from: :scholarship_shortlisted, to: :scholarship_granted
    end

    event :no_scholarship do
      transitions from: :scholarship_shortlisted, to: :admitted
    end

    event :payment do
      transitions from: [ :admitted, :deposit_paid, :extension ], to: :tuition_paid # TODO:, guard: paid_for?(bootcamp.tuition)
      transitions from: :admitted, to: :deposit_paid # TODO:, guard: paid_for?(bootcamp.deposit)
      transitions from: :admitted, to: :admitted
      transitions from: :deposit_paid, to: :deposit_paid
      transitions from: :tuition_paid, to: :tuition_paid
      transitions from: :extension, to: :extension
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

  def similar
    AppForm.where('(firstname = ? AND lastname = ? OR email = ?) AND klass_id <> ?', firstname, lastname, email, klass_id)
  end

  # scopes available for external querying
  def self.searches
    {
      applications: self.all,
      # TODO: replace these
      today: self.where('created_at >= ?', Date.today),
      # TODO: replace with count of applications w/o votes
      # TODO: replace with count of applications for each class team member to review
      # TODO: "limbo:" apps reviewed by all team members but not progressed

      round_1_interviews: self.where('aasm_state in (?)', [:invite_email_sent, :interview_scheduled, :unable_to_interview, :interviewed, :waitlisted, :admitted, :scholarship_shortlisted, :scholarship_granted, :deposit_paid, :extension, :tuition_paid, :rejected_after_interview, :not_coming]),
      scheduled: self.where('aasm_state = ?', :interview_scheduled),
      completed: self.where('aasm_state in (?)', [:unable_to_interview, :interviewed, :waitlisted, :admitted, :scholarship_shortlisted, :scholarship_granted, :deposit_paid, :extension, :tuition_paid, :rejected_after_interview, :not_coming]),
      round_1_rejected: self.where('aasm_state in (?)', [:decided_to_reject_application, :application_reject_email_sent]),

      adcom_decision: self.where('aasm_state in (?)', [:interviewed, :waitlisted, :admitted, :scholarship_shortlisted, :scholarship_granted, :deposit_paid, :extension, :tuition_paid, :rejected_after_interview, :not_coming]),
      waiting_decision: self.where('aasm_state = ?', :interviewed),
      decision_made: self.where('aasm_state in (?)', [:waitlisted, :admitted, :scholarship_shortlisted, :scholarship_granted, :deposit_paid, :extension, :tuition_paid, :rejected_after_interview, :not_coming]),
      rejected: self.where('aasm_state = ?', :rejected_after_interview),
      waitlist: self.where('aasm_state = ?', :waitlisted),
      admitted: self.where('aasm_state in (?)', [:admitted, :scholarship_shortlisted, :scholarship_granted, :not_coming, :deposit_paid, :extension, :tuition_paid]),
      scholarship: self.where('aasm_state = ?', :scholarship_granted),
      no_scholarship: self.where('aasm_state in (?)', [:admitted, :deposit_paid, :tuition_paid, :extension]),
      shortlist: self.where('aasm_state = ?', :scholarship_shortlisted),

      without_scholarship: self.where('aasm_state in (?)', [:admitted, :deposit_paid, :tuition_paid]),
      deposit_pending: self.where('aasm_state = ?', :admitted),
      tuition_pending: self.where('aasm_state in (?)', [:admitted, :deposit_paid]),
      not_coming: self.where('aasm_state = ?', :not_coming),
      extension: self.where('aasm_state = ?', :extension),

      invite_emails_pending: self.where('aasm_state = ?', :decided_to_invite),
      reject_emails_pending: self.where('aasm_state = ?', :decided_to_reject_application),
    }
  end
end
