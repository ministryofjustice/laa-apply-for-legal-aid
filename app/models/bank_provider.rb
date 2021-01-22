class BankProvider < ApplicationRecord
  belongs_to :applicant
  has_many :bank_account_holders, dependent: :destroy
  has_many :bank_accounts, dependent: :destroy
  has_one :main_account_holder, -> { order created_at: :desc }, class_name: 'BankAccountHolder', inverse_of: :bank_provider
  has_one :legal_aid_application, through: :applicant
end
