class BankAccount < ApplicationRecord
  belongs_to :bank_provider
  has_many :bank_transactions, dependent: :destroy
  has_one :legal_aid_application, through: :bank_provider

  ACCOUNT_TYPE_LABELS = {
    'TRANSACTION' => 'Bank Current',
    'SAVINGS' => 'Bank Savings'
  }.freeze

  scope :current, -> { where(account_type: 'TRANSACTION') }
  scope :savings, -> { where.not(account_type: 'TRANSACTION') }

  def latest_balance
    return 0.0 if bank_transactions.empty?

    bank_transactions.most_recent_first.limit(1).first.running_balance
  end

  def account_type_label
    ACCOUNT_TYPE_LABELS.fetch(account_type, account_type)
  end

  def holder_type
    'Client Sole'
  end

  def display_name
    "#{bank_provider.name} Acct #{account_number}"
  end

  def ccms_instance_name(count)
    "the bank account#{count}"
  end

  def bank_and_account_name
    "#{bank_provider.name} #{name}"
  end

  # rubocop:disable Naming/PredicateName
  def has_tax_credits?
    meta_data_codes = bank_transactions.pluck(:meta_data).pluck(:code)
    meta_data_codes.include?('TC') || meta_data_codes.include?('WTC') || meta_data_codes.include?('CTC')
  end

  def has_wages?
    false
  end

  def has_benefits?
    bank_transactions.joins(:transaction_type).where(transaction_type: { name: 'benefits' }).present?
  end
  # rubocop:enable Naming/PredicateName
end
