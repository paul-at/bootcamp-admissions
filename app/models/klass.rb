class Klass < ApplicationRecord
  belongs_to :subject
  belongs_to :payment_tier
  has_many :app_forms
  has_many :admission_committee_members, dependent: :destroy

  validates :title, presence: true

  scope :active, -> { where(archived: false) }
  scope :archived, -> { where(archived: true) }

  def searches
    klass_searches = Hash.new
    AppForm.searches.each { |s,sc| klass_searches[s] = sc.where(klass: self) }
    return klass_searches
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
end
