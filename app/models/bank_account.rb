class BankAccount < ApplicationRecord
  belongs_to :bank_provider
  has_many :bank_transactions, dependent: :destroy
  has_one :legal_aid_application, through: :bank_provider

  ACCOUNT_TYPE_LABELS = {
    'TRANSACTION' => 'Current',
    'SAVINGS' => 'Savings'
  }.freeze

  def account_type_label
    ACCOUNT_TYPE_LABELS.fetch(account_type, account_type)
  end

  # currently hard coded for CCMS payload integration test
  def holders
    'ClientSole'
  end

  def display_name
    "#{b.bank_provider.name} Acct #{b.account_number}"
  end
end
