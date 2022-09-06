class RegularPayment < ApplicationRecord
  FREQUENCIES = %w[weekly monthly].freeze

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
