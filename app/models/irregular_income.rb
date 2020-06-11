class IrregularIncome < ApplicationRecord
  belongs_to :legal_aid_application

  PERMITTED_TYPES = /student_loan/.freeze
  PERMITTED_FREQUENCY = /annual/.freeze

  validates :income_type, format: { with: PERMITTED_TYPES }
  validates :frequency, format: { with: PERMITTED_FREQUENCY }
end
