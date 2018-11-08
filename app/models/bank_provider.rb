class BankProvider < ApplicationRecord
  belongs_to :applicant
  has_many :bank_account_holders, dependent: :destroy
  has_many :bank_accounts, dependent: :destroy
end
