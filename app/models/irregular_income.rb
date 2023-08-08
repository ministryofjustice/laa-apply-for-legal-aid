class IrregularIncome < ApplicationRecord
  belongs_to :legal_aid_application

  validates :income_type, inclusion: %w[student_loan]
  validates :frequency, inclusion: %w[annual]

  scope :student_finance, -> { where(income_type: "student_loan") }

  def label
    income_type.humanize
  end
end
