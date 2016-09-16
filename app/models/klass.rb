class Klass < ApplicationRecord
  belongs_to :subject
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
end
