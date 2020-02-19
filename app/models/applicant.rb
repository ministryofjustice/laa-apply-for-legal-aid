require 'uri'
require 'omniauth'

class Applicant < ApplicationRecord
  devise

  NINO_REGEXP = /^[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}$/.freeze

  has_one :legal_aid_application, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_one :address, -> { order(created_at: :desc) }
  has_many :bank_providers, dependent: :destroy
  has_many :bank_errors, dependent: :destroy
  has_many :bank_accounts, through: :bank_providers
  has_many :bank_transactions, through: :bank_accounts
  belongs_to :true_layer_secure_data, class_name: :SecureData, optional: true

  def email_address
    email
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def store_true_layer_token(token:, expires:)
    data = { token: token, expires: expires }
    update!(true_layer_secure_data_id: SecureData.create_and_store!(data))
  end

  def true_layer_token
    true_layer_token_data[:token]
  end

  def true_layer_token_expires_at
    Time.parse(true_layer_token_data[:expires]) if true_layer_token_data[:expires]
  end

  def true_layer_token_data
    @true_layer_token_data = true_layer_secure_data.retrieve
  end

  def age
    AgeCalculator.call(date_of_birth, legal_aid_application.calculation_date)
  end

  def child?
    age < 16
  end

  def receives_financial_support?
    return false if bank_transactions.empty?

    bank_transactions.map(&:transaction_type_id).include?(TransactionType.find_by(name: 'friends_or_family')&.id)
  end

  def receives_rental_income?
    return false if bank_transactions.empty?

    bank_transactions.map(&:transaction_type_id).include?(TransactionType.find_by(name: 'property_or_lodger')&.id)
  end

  def receives_maintenance?
    maintenance_per_month.to_i.positive?
  end

  def maintenance_per_month
    cfe_result = legal_aid_application&.most_recent_cfe_submission&.result
    return '0.0' unless cfe_result

    JSON.parse(cfe_result.result)['disposable_income']['maintenance_allowance'] || '0.0'
  end
end
