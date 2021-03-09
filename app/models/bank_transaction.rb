class BankTransaction < ApplicationRecord
  belongs_to :bank_account
  belongs_to :transaction_type, optional: true
  has_one :legal_aid_application, through: :bank_account

  serialize :meta_data

  attr_accessor :previous_txn_id, :next_txn_id

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

  scope :most_recent_first, -> { order(happened_at: :desc, created_at: :desc) }

  scope :by_account_most_recent_first, -> { order(bank_account_id: :asc, happened_at: :desc, created_at: :desc) }

  enum operation: {
    credit: 'credit'.freeze,
    debit: 'debit'.freeze
  }

  def self.amounts
    group(:transaction_type_id).sum(:amount)
  end

  def self.for_type(transaction_type_name)
    transaction_type = TransactionType.find_by(name: transaction_type_name)
    return [] if transaction_type.nil?

    where(transaction_type_id: transaction_type.id)
  end

  def parent_transaction_type
    transaction_type.parent_or_self
  end
end
