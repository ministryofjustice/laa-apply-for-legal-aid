class LegalAidApplicationTransactionType < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :transaction_type

  scope :credits, -> { includes(:transaction_type).where(transaction_types: { operation: :credit }) }
  scope :debits, -> { includes(:transaction_type).where(transaction_types: { operation: :debit }) }
end
