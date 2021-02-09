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

  def holder_type
    'Client Sole'
  end

  def display_name
    "#{bank_provider.name} Acct #{account_number}"
  end

  def bank_and_account_name
    "#{bank_provider.name} #{name}"
  end

  # rubocop:disable Naming/PredicateName
  def has_tax_credits?
    tax_credits = bank_transactions.pluck(:meta_data).map { |transaction| transaction[:code] }
    tax_credits.include?('TC') || tax_credits.include?('WTC') || tax_credits.include?('CTC')
  end

  def has_wages?
    false
  end

  def has_benefits?
    benefits = bank_transactions.joins(:transaction_type).where(transaction_type: { name: 'benefits' })
    benefits.present?
  end
  # rubocop:enable Naming/PredicateName
end
