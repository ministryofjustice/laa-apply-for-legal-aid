class BankTransaction < ApplicationRecord
  belongs_to :bank_account
  belongs_to :transaction_type, optional: true

  scope :of_applicant, ->(applicant) do
    joins(bank_account: { bank_provider: :applicant })
      .where(bank_accounts: { bank_providers: { applicant: applicant } })
      .order(happened_at: :desc, id: :desc)
  end

  enum operation: {
    credit: 'credit'.freeze,
    debit: 'debit'.freeze
  }
end
