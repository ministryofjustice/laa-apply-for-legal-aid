class BankProvider < ApplicationRecord
  belongs_to :applicant

  has_many :bank_account_holders, dependent: :destroy
  has_many :bank_accounts, dependent: :destroy

  has_one :main_account_holder, -> { order created_at: :desc }, class_name: "BankAccountHolder", inverse_of: :bank_provider, dependent: :destroy
  has_one :legal_aid_application, through: :applicant

  validates :true_layer_provider_id, uniqueness: { scope: :applicant }
end
