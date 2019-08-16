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
    date = legal_aid_application.submission_date
    age = date.year - date_of_birth.year
    date_of_birth > date.years_ago(age) ? age - 1 : age
  end
end
