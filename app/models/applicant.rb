require 'uri'
require 'omniauth'

class Applicant < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:true_layer]

  NINO_REGEXP = /^[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}$/.freeze

  has_one :legal_aid_application, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_one :address, -> { order(created_at: :desc) }
  has_many :bank_providers, dependent: :destroy
  has_many :bank_errors, dependent: :destroy
  has_many :bank_accounts, through: :bank_providers
  has_many :bank_transactions, through: :bank_accounts

  def email_address
    email
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
