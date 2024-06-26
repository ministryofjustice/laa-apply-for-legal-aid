class RegularTransaction < ApplicationRecord
  FREQUENCIES = %w[weekly two_weekly four_weekly monthly three_monthly].freeze

  belongs_to :legal_aid_application
  belongs_to :transaction_type

  validates :amount, currency: { greater_than: 0 }
  validates :frequency, inclusion: { in: ->(transaction) { frequencies_for(transaction.transaction_type) } }

  def self.credits
    includes(:transaction_type).where(transaction_types: { operation: :credit })
  end

  def self.debits
    includes(:transaction_type).where(transaction_types: { operation: :debit })
  end

  def self.frequencies_for(transaction_type)
    transaction_type.name == "benefits" ? FREQUENCIES.excluding("monthly", "three_monthly") : FREQUENCIES
  end
end
