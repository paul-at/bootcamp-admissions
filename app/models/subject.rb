class Subject < ApplicationRecord
    has_many :klasses

    validates :title, presence: true
end
