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

  # Class-wide searches
  def app_forms_that_are(condition)
    app_forms.visible.where(app_forms_by_klass_conditions[condition])
  end

  # Field acessors
  def full_title
    subject.title + ' ' + self.title
  end

  def scoring_criteria
    self[:scoring_criteria] || ''
  end

  def scoring_criteria_as_array
    @scoring_criteria_as_array ||= scoring_criteria
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

  # SQL statistics
  def todo_statistics
    AppForm.connection.select_all("SELECT
      SUM(CASE WHEN aasm_state = 'applied' THEN 1 ELSE 0 END) AS applied,
      SUM(CASE WHEN #{app_forms_by_klass_conditions[:ready_to_screen]} THEN 1 ELSE 0 END) AS to_screen,
      SUM(CASE WHEN #{app_forms_by_klass_conditions[:interviews_to_assign]} THEN 1 ELSE 0 END) AS interviews_to_assign,
      SUM(CASE WHEN #{app_forms_by_klass_conditions[:recommended_to_reject]} THEN 1 ELSE 0 END) AS reject,
      SUM(CASE WHEN #{app_forms_by_klass_conditions[:recommended_to_admit]} THEN 1 ELSE 0 END) AS admit,
      SUM(CASE WHEN #{app_forms_by_klass_conditions[:recommended_to_scholarship]} THEN 1 ELSE 0 END) AS scholarship
    FROM app_forms
    WHERE
      klass_id = #{id} AND
      deleted = false",
     ).to_ary[0]
  end

  # SQL queries for selecting AppForms where condition is calculated based on Klass settings
  def app_forms_by_klass_conditions(interviewer_id = nil)
    if interviewer_id || @app_forms_by_klass_conditions.nil?
      @app_forms_by_klass_conditions = {
        ready_to_screen: "aasm_state = 'applied' AND (SELECT COUNT(*) FROM votes WHERE app_form_id = app_forms.id) >= #{consensus}",
        interviews_to_assign: "aasm_state IN ('decided_to_invite', 'invite_email_sent') AND interviewer_id IS NULL",
        recommended_to_reject: "aasm_state = 'interviewed' AND
          (SELECT AVG(score) FROM scores WHERE app_form_id = app_forms.id) *
          #{scoring_criteria_as_array.count} < #{admission_threshold || 0}",
        recommended_to_admit: "aasm_state = 'interviewed' AND
          (SELECT AVG(score) FROM scores WHERE app_form_id = app_forms.id) *
          #{scoring_criteria_as_array.count} >= #{admission_threshold || max_score+1}",
        recommended_to_scholarship: "aasm_state = 'interviewed' AND
          (SELECT AVG(score) FROM scores WHERE app_form_id = app_forms.id) *
          #{scoring_criteria_as_array.count} >= #{scholarship_threshold || max_score+1}",
        applicants_to_interview: "aasm_state IN ('interview_scheduled', 'invite_email_sent') " +
          (interviewer_id ? " AND interviewer_id = #{interviewer_id}" : ''),
        interviews_to_score: "aasm_state = 'interviewed' " +
          (interviewer_id ? " AND interviewer_id = #{interviewer_id}
            AND (SELECT COUNT(*) FROM scores WHERE app_form_id = app_forms.id AND user_id = #{interviewer_id}) = 0" : ''),
      }
    else
      @app_forms_by_klass_conditions
    end
  end
end
