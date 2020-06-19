class IrregularIncome < ApplicationRecord
  belongs_to :legal_aid_application

  validates :income_type, inclusion: %w[student_loan]
  validates :frequency, inclusion: %w[annual]

  def as_json(_options = nil)
    {
      income_type: income_type,
      frequency: frequency,
      amount: amount.to_f
    }
  end

  scope :student_finance, -> { where(income_type: 'student_loan') }
end
