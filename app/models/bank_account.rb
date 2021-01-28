class BankAccount < ApplicationRecord
  belongs_to :bank_provider
  has_many :bank_transactions, dependent: :destroy
  has_one :legal_aid_application, through: :bank_provider

  ACCOUNT_TYPE_LABELS = {
    'TRANSACTION' => 'Current',
    'SAVINGS' => 'Savings'
  }.freeze

  scope :current, -> { where(account_type: 'TRANSACTION') }
  scope :savings, -> { where.not(account_type: 'TRANSACTION') }

  def latest_balance
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

  def bank_and_account_name
    "#{bank_provider.name} #{name}"
  end

  # rubocop:disable Naming/PredicateName
  def has_tax_credits?
    true # TODO: CCMS placeholder - to be fixed by AP-1965
  end

  def has_wages?
    true # TODO: CCMS placeholder - to be fixed by AP-1965
  end

  def has_benefits?
    true # TODO: CCMS placeholder - to be fixed by AP-1965
  end
  # rubocop:enable Naming/PredicateName
end
