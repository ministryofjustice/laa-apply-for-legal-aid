require "uri"
require "omniauth"

class Applicant < ApplicationRecord
  devise :rememberable

  NINO_REGEXP = /\A[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}\z/

  enum :correspondence_address_choice, {
    home: "home".freeze,
    residence: "residence".freeze,
    office: "office".freeze,
  }

  has_one :legal_aid_application, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_one :address, -> { where(location: "correspondence").order(created_at: :desc) }, inverse_of: :applicant, dependent: :destroy
  has_one :home_address, -> { where(location: "home").order(created_at: :desc) }, class_name: "Address", inverse_of: :applicant, dependent: :destroy
  has_many :bank_providers, dependent: :destroy
  has_many :bank_errors, dependent: :destroy
  has_many :bank_accounts, through: :bank_providers
  has_many :bank_transactions, through: :bank_accounts
  has_many :regular_transactions, as: :owner
  has_many :hmrc_responses, class_name: "HMRC::Response", as: :owner
  has_many :employments, as: :owner

  encrypts :encrypted_true_layer_token

  delegate :transaction_period_start_on, to: :legal_aid_application

  def has_partner_with_no_contrary_interest?
    has_partner && !partner_has_contrary_interest
  end

  def email_address
    email
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def surname_at_birth
    # used by CCMS generators
    last_name_at_birth.presence || last_name
  end

  def true_layer_token
    encrypted_true_layer_token&.fetch("token", nil)
  end

  def age
    return age_for_means_test_purposes if legal_aid_application&.non_means_tested?

    AgeCalculator.call(date_of_birth, legal_aid_application.calculation_date)
  end

  def no_means_test_required?
    under_18?
  end

  def under_18?
    age_for_means_test_purposes.present? &&
      age_for_means_test_purposes < 18
  end

  def over_17?
    age_for_means_test_purposes.present? &&
      age_for_means_test_purposes >= 17
  end

  def child?
    age < 16
  end

  def not_employed?
    !employed && !self_employed? && !armed_forces?
  end

  def json_for_hmrc
    {
      first_name:,
      last_name:,
      dob: date_of_birth,
      nino: national_insurance_number,
    }
  end

  def receives_financial_support?
    bank_transactions.for_type("friends_or_family").present?
  end

  def receives_maintenance?
    maintenance_per_month.to_i.positive?
  end

  def maintenance_per_month
    return "0.0" unless valid_cfe_result_version?

    sprintf("%<amount>.2f", amount: cfe_result.maintenance_per_month || 0)
  end

  delegate :type, to: :cfe_result, prefix: true

  def cfe_result
    legal_aid_application&.most_recent_cfe_submission&.result
  end

  def valid_cfe_result_version?
    [CFE::V3::Result, CFE::V4::Result, CFE::V5::Result].any? { |klass| cfe_result_type == klass.to_s }
  end

  def mortgage_per_month
    return "0.0" unless valid_cfe_result_version?

    sprintf("%<amount>.2f", amount: cfe_result.mortgage_per_month || 0)
  end

  def employment_status
    employed? ? I18n.t("activemodel.attributes.applicant.employed") : I18n.t("activemodel.attributes.applicant.not_employed")
  end

  def state_benefits
    regular_transactions.where(transaction_type_id: TransactionType.find_by(name: "benefits")).order(:created_at)
  end

  def hmrc_employment_income?
    employments.any?
  end

  def has_multiple_employments?
    employments.length > 1
  end

  def eligible_employment_payments
    employment_payments.select { |p| p.date >= transaction_period_start_on }
  end

  def employment_payments
    employments.map(&:employment_payments).flatten
  end

  def home_address_for_ccms
    return if no_fixed_residence?

    home_address.presence || address
  end

  def correspondence_address_for_ccms
    same_correspondence_and_home_address? ? home_address : address
  end
end
