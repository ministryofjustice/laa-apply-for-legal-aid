class BankAccount < ApplicationRecord
  belongs_to :bank_provider
  has_many :bank_transactions, dependent: :destroy
end
