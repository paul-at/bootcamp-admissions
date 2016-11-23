class Klass < ApplicationRecord
  belongs_to :subject
  belongs_to :payment_tier
  has_many :app_forms
  has_many :admission_committee_members, dependent: :destroy
  has_many :email_rules, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  validates :title, presence: true

  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }

  def self.active_for_select
    self.active.collect{ |klass| [ klass.full_title, klass.id ] }
  end

  def searches
    klass_searches = Hash.new
    AppForm.searches.
      merge(AppForm.dynamic_screening_searches(admission_committee_members.map(&:user))).
      each { |s,sc| klass_searches[s] = sc.where(klass: self, deleted: false) }
    return klass_searches
  end

  def dynamic_screening_searches_names
    AppForm.dynamic_screening_searches_names(admission_committee_members.map(&:user))
  end

  def full_title
    subject.title + ' ' + self.title
  end

  def scoring_criteria
    self[:scoring_criteria] || ''
  end

  def scoring_criteria_as_array
    scoring_criteria
      .split("\n")
      .map{|criterion| criterion.gsub(/[^\w ]/,'')}
      .reject{|criterion| criterion.empty?}
  end

  def max_score
    scoring_criteria_as_array.count * 5
  end

  def consensus
    (admission_committee_members.count / 2.0).ceil
  end

  def todo_statistics
    AppForm.connection.select_all("SELECT
      SUM(CASE WHEN aasm_state = 'applied' THEN 1 ELSE 0 END) AS applied,
      SUM(CASE WHEN aasm_state = 'applied' AND (SELECT COUNT(*) FROM votes WHERE app_form_id = app_forms.id) >= #{consensus} THEN 1 ELSE 0 END) AS to_screen,
      SUM(CASE WHEN aasm_state IN ('decided_to_invite', 'invite_email_sent') AND interviewer_id IS NULL THEN 1 ELSE 0 END) AS interviews_to_assign,
      SUM(CASE WHEN aasm_state = 'interviewed' AND
        (SELECT AVG(score) FROM scores WHERE app_form_id = app_forms.id) *
        #{scoring_criteria_as_array.count} < #{admission_threshold || 0} THEN 1 ELSE 0 END) AS reject,
      SUM(CASE WHEN aasm_state = 'interviewed' AND
        (SELECT AVG(score) FROM scores WHERE app_form_id = app_forms.id) *
        #{scoring_criteria_as_array.count} >= #{admission_threshold || max_score+1} THEN 1 ELSE 0 END) AS admit,
      SUM(CASE WHEN aasm_state = 'interviewed' AND
        (SELECT AVG(score) FROM scores WHERE app_form_id = app_forms.id) *
        #{scoring_criteria_as_array.count} >= #{scholarship_threshold || max_score+1} THEN 1 ELSE 0 END) AS scholarship
    FROM app_forms
    WHERE
      klass_id = #{id} AND
      deleted = false",
     ).to_ary[0]
  end
end
