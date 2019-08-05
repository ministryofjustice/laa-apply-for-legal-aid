class BankTransaction < ApplicationRecord
  belongs_to :bank_account
  belongs_to :transaction_type, optional: true
  has_one :legal_aid_application, through: :bank_account

  scope :by_type, -> do
    includes(:transaction_type)
      .where.not(transaction_type_id: nil)
      .group_by(&:transaction_type)
  end

  enum operation: {
    credit: 'credit'.freeze,
    debit: 'debit'.freeze
  }

  def self.amounts
    group(:transaction_type_id).sum(:amount)
  end
end
