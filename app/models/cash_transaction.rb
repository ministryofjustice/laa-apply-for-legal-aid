class CashTransaction < ApplicationRecord
  belongs_to :legal_aid_application
  belongs_to :transaction_type

  validates :amount, presence: true

  scope :income, -> { where(type: 'CashTransaction::Income').order(:sort_order) }
  scope :outgoing, -> { where(type: 'CashTransaction::Outgoing').order(:sort_order) }
end
