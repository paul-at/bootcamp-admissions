class AppForm < ApplicationRecord
  include AASM

  belongs_to :klass
  belongs_to :payment_tier
  belongs_to :interviewer, class_name: 'User'
  has_many :answers, -> { order(:question) }, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_many :histories, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :scores, dependent: :destroy
  has_many :interview_notes, dependent: :destroy
  has_many :emails, dependent: :destroy

  attr_accessor :log_user

  aasm enum: false do
    state :applied, initial: true
    state :decided_to_invite, :invite_email_sent, :decided_to_reject_application, :application_reject_email_sent
    state :interview_scheduled, :interviewed, :rejected_after_interview, :invite_no_response, :no_show
    state :decision_reject_email_sent, :waitlist_email_sent, :admit_email_sent
    state :admitted, :waitlisted, :extension, :deposit_paid, :tuition_paid, :not_coming
    state :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded
    state :coming

    after_all_transitions [:log_status_change, :run_email_templates]

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

    event :no_show do
      transitions from: :interview_scheduled, to: :no_show
    end

    event :wont_come do
      transitions from: [ :admit_email_sent, :scholarship_not_awarded, :extension, :scholarship_awarded, :deposit_paid, :tuition_paid ], to: :not_coming
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
      transitions from: [ :admit_email_sent, :scholarship_not_awarded, :deposit_paid, :extension ], to: :tuition_paid, guard: :tuition_paid?
      transitions from: [ :admit_email_sent, :scholarship_not_awarded ], to: :deposit_paid, guard: :deposit_paid?
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
  validates :country, length: { maximum: 2 }
  validates :residence, length: { maximum: 2 }
  #validates :city, presence: true
  #validates :residence_city, presence: true
  #validates :gender, presence: true, length: { is: 1 }
  #validates :dob, presence: true

  def age
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def similar
    AppForm.where('(firstname = ? AND lastname = ? OR email = ?) AND id <> ?', firstname, lastname, email, id)
  end

  def scores_for(user)
    if scores.where(user: user).count > 0
      scores_array = scores.where(user: user)
    else
      scores_array = klass.scoring_criteria_as_array.map do |criterion|
        Score.new({
          app_form: self,
          user: user,
          criterion: criterion,
        })
      end
    end
    UserScores.new(scores_array)
  end

  def average_score
    return 0 if scores.empty?
    total = scores.map(&:score).compact.reduce(:+)
    total * klass.scoring_criteria_as_array.count / scores.count
  end

  def full_name
    "#{firstname} #{lastname}"
  end

  def full_email
    "\"#{full_name}\" <#{email}>"
  end

  def can_change_interviewer?
    [ :applied, :decided_to_invite, :invite_email_sent, :interview_scheduled ].include?(self.aasm_state.to_sym)
  end

  def run_email_templates
    EmailRule.where(klass_id: klass_id, state: aasm.to_state).each do |rule|
      rule.create_email_for(self)
    end
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
      #_invite_emails_sent: self.where('aasm_state in (?)', [:invite_email_sent, :interview_scheduled, :invite_no_response, :no_show, :interviewed, :waitlisted, :waitlist_email_sent, :admitted, :admit_email_sent, :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded, :deposit_paid, :extension, :tuition_paid, :rejected_after_interview, :decision_reject_email_sent, :coming, :not_coming]),

      interviews_rejected: self.where('aasm_state in (?)', [:decided_to_reject_application, :application_reject_email_sent]),
      #_interview_reject_emails_sent: self.where('aasm_state = ?', :application_reject_email_sent),
      _interview_reject_emails_pending: self.where('aasm_state = ?', :decided_to_reject_application),
      not_reviewed: self.where('aasm_state = ?', :applied),

      none_reviewed: self.where('aasm_state = ? AND (SELECT COUNT(*) FROM votes WHERE votes.app_form_id = app_forms.id) = 0', :applied),

      interviewed: self.where('aasm_state in (?)', [:interviewed, :waitlisted, :waitlist_email_sent, :admitted, :admit_email_sent, :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded, :deposit_paid, :extension, :tuition_paid, :rejected_after_interview, :decision_reject_email_sent, :coming, :not_coming]),
      no_show: self.where('aasm_state = ?', :no_show),

      decided_to_invite: self.where('aasm_state = ?', :decided_to_invite),
      invite_emails_sent: self.where('aasm_state = ?', :invite_email_sent),
      interviews_scheduled: self.where('aasm_state = ?', :interview_scheduled),
      invite_no_response: self.where('aasm_state = ?', :invite_no_response),


      admitted: self.where('aasm_state in (?)', [:admitted, :admit_email_sent, :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded, :deposit_paid, :extension, :tuition_paid, :coming, :not_coming]),
      _admit_emails_pending: self.where('aasm_state = ?', :admitted),
      #_admit_emails_sent: self.where('aasm_state in (?)', [:admit_email_sent, :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded, :deposit_paid, :extension, :tuition_paid, :coming, :not_coming]),

      rejected: self.where('aasm_state in (?)', [:rejected_after_interview, :decision_reject_email_sent]),
      #_reject_emails_sent: self.where('aasm_state = ?', :decision_reject_email_sent),
      _reject_emails_pending: self.where('aasm_state = ?', :rejected_after_interview),

      waitlisted: self.where('aasm_state in (?)', [:waitlisted, :waitlist_email_sent]),
      #_waitlist_emails_sent: self.where('aasm_state = ?', :waitlist_email_sent),
      _waitlist_emails_pending: self.where('aasm_state = ?', :waitlisted),

      interviewed_and_in_limbo: self.where('aasm_state = ?', :interviewed),
    }
  end

  def self.dynamic_screening_searches(admission_committee_members)
    i = 0
    names = self.dynamic_screening_searches_names(admission_committee_members)
    result = Hash.new
    admission_committee_members.each do |user|
      result[names[i]] = self.where('aasm_state = ? AND (SELECT COUNT(*) FROM votes WHERE votes.app_form_id = app_forms.id AND votes.user_id = ?) = 0', :applied, user.id)
      i += 1
    end
    result[names[i]] = self.where("aasm_state = ? AND (SELECT COUNT(*) FROM (SELECT DISTINCT user_id FROM votes WHERE app_form_id = app_forms.id) AS temp) >= ?", :applied, admission_committee_members.count)
    result
  end

  def self.dynamic_screening_searches_names(admission_committee_members)
    admission_committee_members.map(&:name).map{|user| "for_#{user}_review".to_sym } + [:reviewed_and_in_limbo]
  end

  def self.states_for_select
    self.aasm.states.collect{|state| [state.name.to_s.humanize, state.name] }
  end

  private
  def deposit_paid?
    return false unless payment_tier
    paid >= payment_tier.deposit
  end

  def tuition_paid?
    return false unless payment_tier
    paid >= payment_tier.tuition
  end

  def log_status_change
    History.create({
      app_form: self, 
      text: "Action #{aasm.current_event.to_s.humanize}",
      from: aasm.from_state.to_s.humanize,
      to: aasm.to_state.to_s.humanize,
      user: @log_user,
    })
  end
end
