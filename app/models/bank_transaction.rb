class BankTransaction < ApplicationRecord
  belongs_to :bank_account
  belongs_to :transaction_type, optional: true
  has_one :legal_aid_application, through: :bank_account

  serialize :meta_data

  scope :by_type, -> do
    includes(:transaction_type)
      .where.not(transaction_type_id: nil)
      .group_by(&:transaction_type)
  end

  scope :by_parent_transaction_type, -> do
    includes(:transaction_type)
      .where.not(transaction_type_id: nil)
      .group_by(&:parent_transaction_type)
  end

  enum operation: {
    credit: 'credit'.freeze,
    debit: 'debit'.freeze
  }

  def self.amounts
    group(:transaction_type_id).sum(:amount)
  end

  def self.for_type(transaction_type_name)
    transaction_type = TransactionType.where(name: transaction_type_name).first
    return [] if transaction_type.nil?

    where(transaction_type_id: transaction_type.id)
  end

  def parent_transaction_type
    transaction_type.parent_or_self
  end
end
