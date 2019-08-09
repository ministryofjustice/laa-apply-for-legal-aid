class BenefitType < ApplicationRecord
  validates :label, uniqueness: true
end
