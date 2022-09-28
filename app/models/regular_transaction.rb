class RegularTransaction < ApplicationRecord
  FREQUENCIES = %w[every_week every_two_weeks every_four_weeks monthly total_in_last_three_months].freeze

  belongs_to :legal_aid_application
  belongs_to :transaction_type

  validates :amount, currency: { greater_than: 0 }
  validates :frequency, inclusion: { in: FREQUENCIES }

  def self.credits
    includes(:transaction_type).where(transaction_types: { operation: :credit })
  end

  def self.debits
    includes(:transaction_type).where(transaction_types: { operation: :debit })
  end
end
