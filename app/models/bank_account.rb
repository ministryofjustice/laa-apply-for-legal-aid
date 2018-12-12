class BankAccount < ApplicationRecord
  belongs_to :bank_provider
  has_many :bank_transactions, dependent: :destroy

  ACCOUNT_TYPE_LABELS = {
    'TRANSACTION' => 'Current',
    'SAVINGS' => 'Savings'
  }.freeze

  def account_type_label
    ACCOUNT_TYPE_LABELS.fetch(account_type, account_type)
  end
end
