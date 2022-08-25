class LegalAidApplicationTransactionType < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :transaction_type

  scope :credits, -> { includes(:transaction_type).where(transaction_types: { operation: :credit }) }
  scope :debits, -> { includes(:transaction_type).where(transaction_types: { operation: :debit }) }

  # TODO: after_destroy instead??
  after_commit :cascade_delete_cash_transactions, on: :destroy

private

  def cascade_delete_cash_transactions
    legal_aid_application
      .cash_transactions
      .where(transaction_type_id:)
      .destroy_all
  end
end
