class BenefitType < ApplicationRecord
  validates :label, uniqueness: true, presence: true
  validates :description, presence: true
end
