require 'csv'

class AppForm < ApplicationRecord
  include AASM

  belongs_to :klass, required: true
  belongs_to :payment_tier
  belongs_to :interviewer, class_name: 'User'
  has_many :answers, -> { order(:question) }, dependent: :destroy
  has_many :attachments, dependent: :destroy
  has_many :histories, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :scores, dependent: :destroy
  has_many :interview_notes, -> { order(updated_at: :desc) }, dependent: :destroy
  has_many :emails, dependent: :destroy

  scope :visible, -> { where(deleted: false) }

  attr_accessor :log_user

  aasm enum: false do
    state :applied, initial: true
    state :decided_to_invite, :invite_email_sent, :decided_to_reject_application, :application_reject_email_sent
    state :interview_scheduled, :interviewed, :rejected_after_interview, :invite_no_response, :no_show
    state :decision_reject_email_sent, :waitlist_email_sent, :admit_email_sent
    state :admitted, :waitlisted, :extension, :deposit_paid, :tuition_paid, :not_coming
    state :scholarship_shortlisted, :scholarship_awarded, :scholarship_not_awarded
    state :attending, :coming

    after_all_transitions [:log_status_change, :run_email_rules]

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
      transitions from: [ :admit_email_sent, :scholarship_not_awarded, :extension, :scholarship_awarded, :deposit_paid, :tuition_paid, :attending ], to: :not_coming
    end

    event :will_come do
      transitions from: [ :scholarship_awarded, :tuition_paid ], to: :coming
    end

    event :admit do
      transitions from: [ :interviewed, :waitlist_email_sent ] , to: :admitted
    end

    event :will_attend do
      transitions from: :admit_email_sent, to: :attending
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
      transitions from: [ :admit_email_sent, :scholarship_not_awarded, :deposit_paid, :extension, :attending ], to: :tuition_paid, guard: :tuition_paid?
      transitions from: [ :admit_email_sent, :scholarship_not_awarded, :attending ], to: :deposit_paid, guard: :deposit_paid?
      transitions from: :admit_email_sent, to: :admit_email_sent
      transitions from: :scholarship_not_awarded, to: :scholarship_not_awarded
      transitions from: :deposit_paid, to: :deposit_paid
      transitions from: :tuition_paid, to: :tuition_paid
      transitions from: :extension, to: :extension
      transitions from: :attending, to: :attending
    end
  end

  validates :firstname, presence: true
  validates :lastname, presence: true
  validates :email, presence: true, uniqueness: { scope: :klass_id, message: 'already applied to this Class' }
  validates :country, length: { maximum: 2 }
  validates :residence, length: { maximum: 2 }
  #validates :city, presence: true
  #validates :residence_city, presence: true
  #validates :gender, presence: true, length: { is: 1 }
  #validates :dob, presence: true

  def age
    return nil unless dob
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

  def run_email_rules
    run_for_state = aasm.to_state || aasm_state # run for current state if no transition in progress
    EmailRule.where(klass_id: klass_id, state: run_for_state).each do |rule|
      rule.create_email_for(self)
    end
  end

  # try to guess country ISO code by country name
  def guess_country
    warnings = Array.new

    country_name = country
    residence_name = residence

    if country_name && country_name.length > 2
      self.country = lookup_isocode(country_name)
      warnings << "Country of origin #{country_name} is not in ISO directory" unless country
    end

    if residence_name && residence_name.length > 2
      self.residence = lookup_isocode(residence_name)
      warnings << "Country of residence #{residence_name} is not in ISO directory" unless residence
    end

    return warnings
  end

  # scopes available for external querying
  def self.searches
    {
      applications: self.all,
      today: self.where('created_at >= ?', Date.today),
      none_reviewed: self.where('aasm_state = ? AND (SELECT COUNT(*) FROM votes WHERE votes.app_form_id = app_forms.id) = 0', :applied),
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

  def self.to_csv
    app_form_attributes = %w(
      id
      aasm_state
      firstname
      lastname
      email
      phone
      country
      residence
      city
      residence_city
      gender
      dob
      referral
      paid
      created_at
      updated_at
      deleted
    )

    relation_attributes = %w(
      Subject
      Class
      Interviewer
      Payment_Tier
    )

    questions = Answer.where(app_form: all).select('question').group('question').map(&:question)

    CSV.generate(headers: true) do |csv|
      csv << app_form_attributes + relation_attributes + questions

      all.includes(klass: [ :subject ], interviewer: [], payment_tier: [], answers: []).each do |app_form|
        fields = app_form_attributes.map{ |attr| app_form.send(attr) }

        # relation attributes
        fields << app_form.klass.subject.title
        fields << app_form.klass.title
        fields << (app_form.interviewer ? app_form.interviewer.name : nil)
        fields << (app_form.payment_tier ? app_form.payment_tier.title : nil)

        # answers
        answers = Hash.new
        app_form.answers.each do |answer|
          answers[answer.question] = answer.answer.gsub(/\s+/, ' ')
        end
        questions.each do |question|
          fields << answers[question]
        end
        csv << fields
      end
    end
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

  def lookup_isocode(country_name)
    return 'US' if country_name.upcase == 'USA'
    c = ISO3166::Country.find_country_by_name(country_name)
    if c
      return c.alpha2
    else
      return nil
    end
  end
end
