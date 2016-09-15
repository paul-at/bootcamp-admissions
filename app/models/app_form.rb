class AppForm < ApplicationRecord
  include AASM

  belongs_to :klass
  has_many :answers

  aasm enum: false do
    state :applied, initial: true
    state :decided_to_invite, :invite_email_sent, :decided_to_reject_application, :application_reject_email_sent
    state :interview_scheduled, :interviewed, :rejected_after_interview, :invite_no_response, :no_show
    state :decision_reject_email_sent, :waitlist_email_sent, :admit_email_sent
    state :admitted, :waitlisted, :extension, :deposit_paid, :tuition_paid, :not_coming
    state :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded
    state :coming

    event :invite do
      transitions from: :applied, to: :decided_to_invite
    end

    event :email_sent do
      transitions from: :decided_to_invite, to: :invite_email_sent
      transitions from: :decided_to_reject_application, to: :application_reject_email_sent
      transitions from: :rejected_after_interview, to: :decision_reject_email_sent
      transitions from: :waitlisted, to: :waitlist_email_sent
      transitions from: :admitted, to: :admit_email_sent
    end

    event :reject do
      transitions from: :applied, to: :decided_to_reject_application
      transitions from: [ :interviewed, :waitlist_email_sent ], to: :rejected_after_interview
    end

    event :schedule_interview do
      transitions from: :invite_email_sent, to: :interview_scheduled
    end

    event :interview do
      transitions from: :interview_scheduled, to: :interviewed
    end

    event :reschedule do
      transitions from: [ :interview_scheduled, :invite_no_response, :no_show ], to: :interview_scheduled
    end

    event :no_response do
      transitions from: :invite_email_sent, to: :invite_no_response
    end

    event :wont_come do
      transitions from: [ :admit_email_sent, :scholarship_not_awarded, :extension, :scholarship_awarded, :deposit_paid, :tuition_paid ], to: :not_coming
      transitions from: :interview_scheduled, to: :no_show
    end

    event :will_come do
      transitions from: [ :scholarship_awarded, :tuition_paid ], to: :coming
    end

    event :admit do
      transitions from: [ :interviewed, :waitlist_email_sent ] , to: :admitted
    end

    event :waitlist do
      transitions from: :interviewed, to: :waitlisted
    end

    event :grant_extension do
      transitions from: [ :admit_email_sent, :scholarship_not_awarded ], to: :extension
    end

    event :shortlist_for_scholarship do
      transitions from: [ :interviewed, :waitlist_email_sent ], to: :scholarship_shortlisted
    end

    event :grant_scholarship do
      transitions from: :scholarship_shortlisted, to: :scholarship_awarded
    end

    event :no_scholarship do
      transitions from: :scholarship_shortlisted, to: :scholarship_not_awarded
    end

    event :payment do
      transitions from: [ :admit_email_sent, :scholarship_not_awarded, :deposit_paid, :extension ], to: :tuition_paid # TODO:, guard: paid_for?(bootcamp.tuition)
      transitions from: [ :admit_email_sent, :scholarship_not_awarded ], to: :deposit_paid # TODO:, guard: paid_for?(bootcamp.deposit)
      transitions from: :admit_email_sent, to: :admit_email_sent
      transitions from: :scholarship_not_awarded, to: :scholarship_not_awarded
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

  def age
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def similar
    AppForm.where('(firstname = ? AND lastname = ? OR email = ?) AND klass_id <> ?', firstname, lastname, email, klass_id)
  end

  # scopes available for external querying
  def self.searches
    {
      applications: self.all,
      today: self.where('created_at >= ?', Date.today),

      coming: self.where('aasm_state = ?', :coming),
      not_coming: self.where('aasm_state = ?', :not_coming),


      interviews: self.where('aasm_state in (?)', [:decided_to_invite, :invite_email_sent, :interview_scheduled, :invite_no_response, :no_show, :interviewed, :waitlisted, :waitlist_email_sent, :admitted, :admit_email_sent, :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded, :deposit_paid, :extension, :tuition_paid, :rejected_after_interview, :decision_reject_email_sent, :coming, :not_coming]),
      _invite_emails_pending: self.where('aasm_state = ?', :decided_to_invite),
      _invite_emails_sent: self.where('aasm_state in (?)', [:invite_email_sent, :interview_scheduled, :invite_no_response, :no_show, :interviewed, :waitlisted, :waitlist_email_sent, :admitted, :admit_email_sent, :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded, :deposit_paid, :extension, :tuition_paid, :rejected_after_interview, :decision_reject_email_sent, :coming, :not_coming]),

      interviews_rejected: self.where('aasm_state in (?)', [:decided_to_reject_application, :application_reject_email_sent]),
      _interview_reject_emails_sent: self.where('aasm_state = ?', :application_reject_email_sent),
      _interview_reject_emails_pending: self.where('aasm_state = ?', :decided_to_reject_application),

      # TODO: count of applications w/o votes
      # TODO: count of applications for each class team member to review
      # TODO: "limbo:" apps reviewed by all team members but not progressed


      interviewed: self.where('aasm_state in (?)', [:interviewed, :waitlisted, :waitlist_email_sent, :admitted, :admit_email_sent, :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded, :deposit_paid, :extension, :tuition_paid, :rejected_after_interview, :decision_reject_email_sent, :coming, :not_coming]),
      no_show: self.where('aasm_state = ?', :no_show),


      admitted: self.where('aasm_state in (?)', [:admitted, :admit_email_sent, :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded, :deposit_paid, :extension, :tuition_paid, :coming, :not_coming]),
      _admit_emails_pending: self.where('aasm_state = ?', :admitted),
      _admit_emails_sent: self.where('aasm_state in (?)', [:admit_email_sent, :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded, :deposit_paid, :extension, :tuition_paid, :coming, :not_coming]),

      rejected: self.where('aasm_state in (?)', [:rejected_after_interview, :decision_reject_email_sent]),
      _reject_emails_sent: self.where('aasm_state = ?', :decision_reject_email_sent),
      _reject_emails_pending: self.where('aasm_state = ?', :rejected_after_interview),

      waitlisted: self.where('aasm_state in (?)', [:waitlisted, :waitlist_email_sent]),
      _waitlist_emails_sent: self.where('aasm_state = ?', :waitlist_email_sent),
      _waitlist_emails_pending: self.where('aasm_state = ?', :waitlisted),
    }
  end
end
